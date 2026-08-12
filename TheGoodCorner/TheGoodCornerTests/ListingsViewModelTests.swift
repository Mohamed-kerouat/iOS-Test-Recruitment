import XCTest
@testable import TheGoodCorner

@MainActor
final class ListingsViewModelTests: XCTestCase {
    func testLoadTransitionsFromLoadingToLoaded() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 1, categoryID: 10)], limit: 20, hasMore: false, page: 1)
        )
        repository.categoriesResult = .success([Category(id: 10, name: "Category")])

        let viewModel = ListingsViewModel(repository: repository)
        XCTAssertTrue(isLoading(viewModel.state))

        await viewModel.load()

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(items.map(\.id), [1])
        XCTAssertEqual(viewModel.categories.map(\.id), [10])
    }

    func testLoadTransitionsFromLoadingToEmpty() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
        )

        let viewModel = ListingsViewModel(repository: repository)

        await viewModel.load()

        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state")
        }
    }

    func testLoadTransitionsFromLoadingToError() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .failure(APIError.server(statusCode: 500))

        let viewModel = ListingsViewModel(repository: repository)

        await viewModel.load()

        guard case let .error(message) = viewModel.state else {
            return XCTFail("Expected error state")
        }

        XCTAssertEqual(message, "The server returned an error (status code: 500).")
    }

    func testFilteringByCategoryPreservesOriginalAPIOrder() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(
                total: 4,
                items: [
                    makeListing(id: 11, categoryID: 1),
                    makeListing(id: 22, categoryID: 2),
                    makeListing(id: 33, categoryID: 1),
                    makeListing(id: 44, categoryID: 3)
                ],
                limit: 20,
                hasMore: false,
                page: 1
            )
        )

        let viewModel = ListingsViewModel(repository: repository)
        await viewModel.load()
        viewModel.selectCategory(id: 1)

        guard case let .loaded(filtered) = viewModel.state else {
            return XCTFail("Expected loaded state after filtering")
        }

        XCTAssertEqual(filtered.map(\.id), [11, 33])
    }

    func testRetryAfterErrorRecoversToLoadedState() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .failure(APIError.transport(URLError(.notConnectedToInternet)))

        let viewModel = ListingsViewModel(repository: repository)
        await viewModel.load()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state after first load")
        }

        repository.listingsResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 99, categoryID: 4)], limit: 20, hasMore: false, page: 1)
        )

        await viewModel.retry()

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state after retry")
        }

        XCTAssertEqual(items.map(\.id), [99])
        XCTAssertEqual(repository.fetchListingsCallCount, 2)
    }

    private func makeListing(id: Int, categoryID: Int) -> Listing {
        Listing(
            id: id,
            isUrgent: false,
            imagesURL: nil,
            creationDate: "2019-11-06T11:22:35Z",
            price: 10,
            description: "description",
            categoryID: categoryID,
            title: "title \(id)"
        )
    }

    private func isLoading(_ state: ViewState<[Listing]>) -> Bool {
        if case .loading = state {
            return true
        }

        return false
    }
}
