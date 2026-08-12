import SwiftUI

// MARK: - Environment Key

private struct APIBaseURLKey: EnvironmentKey {
    static let defaultValue = URL(string: "http://localhost:8080")!
}

extension EnvironmentValues {
    var apiBaseURL: URL {
        get { self[APIBaseURLKey.self] }
        set { self[APIBaseURLKey.self] = newValue }
    }
}

// MARK: - Listing image URL builder

extension Listing {
    /// Builds the full image URL by prepending the server base URL to the
    /// relative path returned by the API. Single centralized location for
    /// this concatenation — not scattered across views.
    func smallImageURL(baseURL: URL) -> URL? {
        guard let path = imagesURL?.small, !path.isEmpty else { return nil }
        return URL(string: path, relativeTo: baseURL)?.absoluteURL
    }
}
