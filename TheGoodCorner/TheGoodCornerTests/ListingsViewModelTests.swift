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

    func testSearchQueriesRepositoryAndShowsServerResults() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 1, categoryID: 1)], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResult = .success(
            ListingsResponse(
                total: 2,
                items: [
                    makeListing(id: 7, categoryID: 1, title: "Mountain bike"),
                    makeListing(id: 9, categoryID: 2, title: "Bike helmet")
                ],
                limit: 20,
                hasMore: false,
                page: 1
            )
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "bike"
        await viewModel.searchTask?.value

        XCTAssertEqual(repository.searchListingsCallCount, 1)
        XCTAssertEqual(repository.lastSearchQuery, "bike")

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state from server search results")
        }
        XCTAssertEqual(items.map(\.id), [7, 9])
    }

    func testSearchComposesWithCategoryFilterAndPreservesOrder() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResult = .success(
            ListingsResponse(
                total: 4,
                items: [
                    makeListing(id: 11, categoryID: 1, title: "Red bike"),
                    makeListing(id: 22, categoryID: 2, title: "Blue bike"),
                    makeListing(id: 33, categoryID: 1, title: "Green bike"),
                    makeListing(id: 44, categoryID: 1, title: "Yellow bike")
                ],
                limit: 20,
                hasMore: false,
                page: 1
            )
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "bike"
        await viewModel.searchTask?.value
        viewModel.selectCategory(id: 1)

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state after combined filtering")
        }
        XCTAssertEqual(items.map(\.id), [11, 33, 44])
    }

    func testSearchWithNoResultsTransitionsToEmpty() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 1, categoryID: 1)], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResult = .success(
            ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "nonexistent"
        await viewModel.searchTask?.value

        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state for no search matches")
        }
        XCTAssertTrue(viewModel.isFiltering)
    }

    func testSearchErrorTransitionsToErrorState() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 1, categoryID: 1)], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResult = .failure(APIError.server(statusCode: 500))

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "bike"
        await viewModel.searchTask?.value

        guard case let .error(message) = viewModel.state else {
            return XCTFail("Expected error state when search fails")
        }
        XCTAssertEqual(message, "The server returned an error (status code: 500).")
    }

    func testClearingSearchRestoresFullFeedWithoutRefetching() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(
                total: 2,
                items: [makeListing(id: 1, categoryID: 1), makeListing(id: 2, categoryID: 1)],
                limit: 20,
                hasMore: false,
                page: 1
            )
        )
        repository.searchResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 99, categoryID: 1)], limit: 20, hasMore: false, page: 1)
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "phone"
        await viewModel.searchTask?.value

        viewModel.searchText = ""
        await viewModel.searchTask?.value

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected the full feed to be restored")
        }
        XCTAssertEqual(items.map(\.id), [1, 2])
        XCTAssertEqual(repository.fetchListingsCallCount, 1)
        XCTAssertEqual(repository.searchListingsCallCount, 1)
    }

    func testRapidTypingIsDebouncedIntoASingleRequest() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResult = .success(
            ListingsResponse(total: 1, items: [makeListing(id: 5, categoryID: 1)], limit: 20, hasMore: false, page: 1)
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .milliseconds(20))
        await viewModel.load()

        viewModel.searchText = "i"
        viewModel.searchText = "ip"
        viewModel.searchText = "iph"
        viewModel.searchText = "iphone"
        await viewModel.searchTask?.value

        XCTAssertEqual(repository.searchListingsCallCount, 1)
        XCTAssertEqual(repository.lastSearchQuery, "iphone")
    }

    func testChangingQuerySupersedesPreviousResult() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
        )
        repository.searchResultsByQuery = [
            "old": .success(
                ListingsResponse(total: 1, items: [makeListing(id: 1, categoryID: 1)], limit: 20, hasMore: false, page: 1)
            ),
            "new": .success(
                ListingsResponse(total: 1, items: [makeListing(id: 2, categoryID: 1)], limit: 20, hasMore: false, page: 1)
            )
        ]

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "old"
        viewModel.searchText = "new"
        await viewModel.searchTask?.value

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state reflecting the latest query")
        }
        XCTAssertEqual(items.map(\.id), [2])
        XCTAssertEqual(repository.lastSearchQuery, "new")
    }

    func testWhitespaceOnlySearchIsIgnored() async {
        let repository = MockListingsRepository()
        repository.listingsResult = .success(
            ListingsResponse(
                total: 2,
                items: [
                    makeListing(id: 1, categoryID: 1),
                    makeListing(id: 2, categoryID: 1)
                ],
                limit: 20,
                hasMore: false,
                page: 1
            )
        )

        let viewModel = ListingsViewModel(repository: repository, searchDebounce: .zero)
        await viewModel.load()

        viewModel.searchText = "   "
        await viewModel.searchTask?.value

        guard case let .loaded(items) = viewModel.state else {
            return XCTFail("Expected loaded state with whitespace-only search")
        }

        XCTAssertEqual(items.map(\.id), [1, 2])
        XCTAssertFalse(viewModel.isFiltering)
        XCTAssertEqual(repository.searchListingsCallCount, 0)
    }

    // MARK: - Helpers

    private func makeListing(id: Int, categoryID: Int, title: String? = nil, description: String = "description") -> Listing {
        Listing(
            id: id,
            isUrgent: false,
            imagesURL: nil,
            creationDate: "2019-11-06T11:22:35Z",
            price: 10,
            description: description,
            categoryID: categoryID,
            title: title ?? "title \(id)"
        )
    }

    private func isLoading(_ state: ViewState<[Listing]>) -> Bool {
        if case .loading = state { return true }
        return false
    }
}
