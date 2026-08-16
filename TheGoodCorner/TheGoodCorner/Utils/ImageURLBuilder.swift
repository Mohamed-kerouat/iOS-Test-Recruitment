import SwiftUI

// MARK: - Environment Key

private struct APIBaseURLKey: EnvironmentKey {
    static let defaultValue = AppConfig.apiBaseURL
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
    ///
    /// Used for the list row thumbnail. Despite the "small" name, this
    /// variant is the lower-resolution one (~80x140px) — appropriate for
    /// a compact row image, not for a larger hero display.
    func smallImageURL(baseURL: URL) -> URL? {
        guard let path = imagesURL?.small, !path.isEmpty else { return nil }
        return URL(string: path, relativeTo: baseURL)?.absoluteURL
    }

    /// Used for the detail screen hero image. Despite the "thumb" name,
    /// this variant is the higher-resolution one (~375x300px) — confirmed
    /// against the server's actual image assets in `server/Public/images/`.
    func thumbImageURL(baseURL: URL) -> URL? {
        guard let path = imagesURL?.thumb, !path.isEmpty else { return nil }
        return URL(string: path, relativeTo: baseURL)?.absoluteURL
    }
}
