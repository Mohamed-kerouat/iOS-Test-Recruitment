import SwiftUI

struct ListingsListView: View {
    @StateObject private var viewModel: ListingsViewModel

    init(repository: ListingsRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ListingsViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    LoadingView()

                case .loaded(let listings):
                    listContent(listings: listings)

                case .empty:
                    EmptyStateView(message: viewModel.isFiltering
                        ? L10n.emptyFilteredListingsMessage
                        : L10n.emptyAllListingsMessage)

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.retry() }
                    }
                }
            }
            .navigationTitle(L10n.listingsNavigationTitle)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: L10n.searchPrompt
            )
            .safeAreaInset(edge: .top) {
                if !viewModel.categories.isEmpty {
                    categoryFilterBar
                }
            }
            .animation(.default, value: viewModel.selectedCategoryID)
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - List content

    private func listContent(listings: [Listing]) -> some View {
        List(listings) { listing in
            NavigationLink(value: listing) {
                ListingRowView(listing: listing, categories: viewModel.categories)
            }
            .accessibilityLabel(listing.title)
        }
        .listStyle(.plain)
        .navigationDestination(for: Listing.self) { listing in
            ListingDetailView(listing: listing, categories: viewModel.categories)
        }
    }

    // MARK: - Category filter bar

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xSmall) {
                filterChip(label: L10n.allCategoriesFilterTitle, id: nil)

                ForEach(viewModel.categories) { category in
                    filterChip(label: category.name, id: category.id)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.xSmall)
        }
        .background(.regularMaterial)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.categoryFilterLabel)
    }

    private func filterChip(label: String, id: Int?) -> some View {
        let isSelected = viewModel.selectedCategoryID == id

        return Button {
            viewModel.selectCategory(id: id)
        } label: {
            Text(label)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, Spacing.xxSmall)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .accessibilityLabel(isSelected ? L10n.selectedFilterAccessibility(label) : label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(L10n.categoryFilterHint(label))
    }
}
