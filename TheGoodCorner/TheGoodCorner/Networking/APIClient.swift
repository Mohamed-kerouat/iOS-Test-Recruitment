import Foundation

@MainActor
final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<T: Decodable>(_ type: T.Type, from path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let url = try makeURL(path: path, queryItems: queryItems)
        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.server(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw APIError.emptyData
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]?) throws -> URL {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path

        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        components.path = baseURL.path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .isEmpty ? "/\(normalizedPath)" : baseURL.path + "/\(normalizedPath)"
        components.queryItems = queryItems?.isEmpty == false ? queryItems : nil

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        return url
    }
}
