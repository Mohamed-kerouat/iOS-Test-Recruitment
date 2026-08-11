import Foundation

@MainActor
protocol ListingsRepositoryProtocol {
    func fetchListings(page: Int?, limit: Int?, query: String?) async throws -> ListingsResponse
    func fetchCategories() async throws -> [Category]
}
