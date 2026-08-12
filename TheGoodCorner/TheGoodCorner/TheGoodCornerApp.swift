import SwiftUI

@main
struct TheGoodCornerApp: App {
    private let baseURL = URL(string: "http://localhost:8080")!

    private let repository: ListingsRepositoryProtocol = {
        let baseURL = URL(string: "http://localhost:8080")!
        let client = APIClient(baseURL: baseURL)
        return ListingsRepository(client: client)
    }()

    var body: some Scene {
        WindowGroup {
            ListingsListView(repository: repository)
                .environment(\.apiBaseURL, baseURL)
        }
    }
}
