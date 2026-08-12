import Foundation
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Listing]> = .loading
    @Published private(set) var categories: [Category] = []
    @Published private(set) var selectedCategoryID: Int?

    private let repository: ListingsRepositoryProtocol
    private var allListings: [Listing] = []

    init(repository: ListingsRepositoryProtocol) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            async let listingsTask = repository.fetchListings(page: nil, limit: nil, query: nil)
            async let categoriesTask = repository.fetchCategories()

            let listingsResponse = try await listingsTask
            categories = try await categoriesTask
            allListings = listingsResponse.items
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

    private func applyFilterAndUpdateState() {
        let filteredListings: [Listing]

        if let selectedCategoryID {
            // Keep API order by filtering the already ordered source array.
            filteredListings = allListings.filter { $0.categoryID == selectedCategoryID }
        } else {
            filteredListings = allListings
        }

        state = filteredListings.isEmpty ? .empty : .loaded(filteredListings)
    }

    private func mapErrorMessage(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Something went wrong. Please try again."
        }

        return "Something went wrong. Please try again."
    }
}
