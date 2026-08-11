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
            return "The request URL could not be created."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .emptyData:
            return "The server returned an empty response."
        case .server(let statusCode):
            return "The server returned an error (status code: \(statusCode))."
        case .transport(let error):
            return error.localizedDescription
        case .decoding(let error):
            return error.localizedDescription
        }
    }
}
