import Foundation

struct ListingsResponse: Codable {
    let total: Int
    let items: [Listing]
    let limit: Int
    let hasMore: Bool
    let page: Int

    enum CodingKeys: String, CodingKey {
        case total
        case items
        case limit
        case hasMore = "has_more"
        case page
    }
}
