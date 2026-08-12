import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyData
    case server(statusCode: Int)
    case transport(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.invalidRequestURLMessage
        case .invalidResponse:
            return L10n.invalidResponseMessage
        case .emptyData:
            return L10n.emptyResponseMessage
        case .server(let statusCode):
            return L10n.serverError(statusCode: statusCode)
        case .transport(let error):
            return error.localizedDescription
        case .decoding(let error):
            return error.localizedDescription
        }
    }
}
