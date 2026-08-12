import Foundation

protocol ListingsRepositoryProtocol {
    func fetchListings() async throws -> ListingsResponse
    func fetchCategories() async throws -> [Category]
}
