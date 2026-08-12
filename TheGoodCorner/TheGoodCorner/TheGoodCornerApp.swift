import SwiftUI

@main
struct TheGoodCornerApp: App {
    private let baseURL = AppConfig.apiBaseURL
    private let repository: ListingsRepositoryProtocol

    init() {
        let client = APIClient(baseURL: baseURL)
        repository = ListingsRepository(client: client)
    }

    var body: some Scene {
        WindowGroup {
            ListingsListView(repository: repository)
                .environment(\.apiBaseURL, baseURL)
        }
    }
}
