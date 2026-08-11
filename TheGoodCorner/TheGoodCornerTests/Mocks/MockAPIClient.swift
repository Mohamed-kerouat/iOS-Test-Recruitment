import Foundation
@testable import TheGoodCorner

@MainActor
final class MockAPIClient: APIClientProtocol {
    var lastPath: String?
    var lastQueryItems: [URLQueryItem]?

    var listingsResponse: ListingsResponse?
    var categoriesResponse: [TheGoodCorner.Category]?
    var errorToThrow: Error?

    func get<T: Decodable>(_ type: T.Type, from path: String, queryItems: [URLQueryItem]?) async throws -> T {
        lastPath = path
        lastQueryItems = queryItems

        if let errorToThrow {
            throw errorToThrow
        }

        if T.self == ListingsResponse.self, let listingsResponse {
            return listingsResponse as! T
        }

        if T.self == [TheGoodCorner.Category].self, let categoriesResponse {
            return categoriesResponse as! T
        }

        fatalError("Unexpected request type: \(T.self)")
    }
}
