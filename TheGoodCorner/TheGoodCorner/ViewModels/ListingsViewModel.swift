import Foundation
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Listing]> = .loading
    @Published private(set) var categories: [Category] = []
    @Published private(set) var selectedCategoryID: Int?
    @Published var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            scheduleSearch()
        }
    }

    private let repository: ListingsRepositoryProtocol
    private let searchDebounce: Duration

    /// The full feed returned by `/listings`, kept so we can restore results
    /// when the search query is cleared without re-hitting the network.
    private var fullFeed: [Listing] = []

    /// The most recent server-side search results. `nil` means no active search,
    /// in which case the full feed is the display source.
    private var searchResults: [Listing]?

    /// The in-flight search work. Exposed for deterministic test synchronization.
    private(set) var searchTask: Task<Void, Never>?

    /// - Parameter searchDebounce: how long to wait after the last keystroke before
    ///   issuing a network request. Injectable so tests can run without real delays.
    init(repository: ListingsRepositoryProtocol, searchDebounce: Duration = .milliseconds(300)) {
        self.repository = repository
        self.searchDebounce = searchDebounce
    }

    func load() async {
        state = .loading

        do {
            async let listingsTask = repository.fetchListings()
            async let categoriesTask = repository.fetchCategories()

            let listingsResponse = try await listingsTask
            categories = try await categoriesTask
            fullFeed = listingsResponse.items
            applyFilterAndUpdateState()
        } catch {
            state = .error(message: mapErrorMessage(error))
        }
    }

    func retry() async {
        await load()
    }

    func selectCategory(id: Int?) {
        selectedCategoryID = id
        applyFilterAndUpdateState()
    }

    /// Indicates whether any filter (category or search) is currently active.
    /// Used by the view to display a context-appropriate empty state message.
    var isFiltering: Bool {
        selectedCategoryID != nil || !trimmedSearchText.isEmpty
    }

    // MARK: - Search

    /// Debounces user input and cancels any in-flight search before starting a new one.
    /// Each keystroke supersedes the previous request, satisfying the requirement to
    /// cancel in-flight requests when the query changes.
    private func scheduleSearch() {
        searchTask?.cancel()

        let query = trimmedSearchText
        searchTask = Task { [weak self] in
            guard let self else { return }

            // Debounce: wait for typing to settle. A cancelled task throws here and exits.
            do {
                try await Task.sleep(for: self.searchDebounce)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            await self.performSearch(query: query)
        }
    }

    private func performSearch(query: String) async {
        // Empty query: drop back to the full feed without a network call.
        guard !query.isEmpty else {
            searchResults = nil
            applyFilterAndUpdateState()
            return
        }

        state = .loading

        do {
            let response = try await repository.searchListings(query: query)
            guard !Task.isCancelled else { return }
            searchResults = response.items
            applyFilterAndUpdateState()
        } catch {
            // Ignore errors surfaced by a superseded/cancelled request.
            guard !Task.isCancelled else { return }
            state = .error(message: mapErrorMessage(error))
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func applyFilterAndUpdateState() {
        // Search results (when present) are the source, otherwise the full feed.
        // Both are already in API display order; filtering preserves it.
        var listings = searchResults ?? fullFeed

        if let selectedCategoryID {
            listings = listings.filter { $0.categoryID == selectedCategoryID }
        }

        state = listings.isEmpty ? .empty : .loaded(listings)
    }

    private func mapErrorMessage(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? L10n.genericErrorMessage
        }

        return L10n.genericErrorMessage
    }
}
