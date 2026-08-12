import Foundation

enum AppConfig {
    private static let defaultAPIBaseURLString = "http://localhost:8080"
    private static let apiBaseURLEnvironmentKey = "THEGOODCORNER_API_BASE_URL"

    static var apiBaseURL: URL {
        if let configuredURL = ProcessInfo.processInfo.environment[apiBaseURLEnvironmentKey],
           let url = URL(string: configuredURL),
           !configuredURL.isEmpty {
            return url
        }

        guard let fallbackURL = URL(string: defaultAPIBaseURLString) else {
            preconditionFailure("Invalid fallback API base URL")
        }

        return fallbackURL
    }
}
