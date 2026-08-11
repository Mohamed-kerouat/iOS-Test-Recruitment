import Foundation

@MainActor
protocol APIClientProtocol {
    func get<T: Decodable>(_ type: T.Type, from path: String, queryItems: [URLQueryItem]?) async throws -> T
}
