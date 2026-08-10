import Foundation

struct Listing: Codable, Identifiable {
    struct ImagesURL: Codable {
        let small: String?
        let thumb: String?
    }

    let id: Int
    let isUrgent: Bool
    let imagesURL: ImagesURL?
    let creationDate: String
    let price: Double
    let description: String
    let categoryID: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case isUrgent = "is_urgent"
        case imagesURL = "images_url"
        case creationDate = "creation_date"
        case price
        case description
        case categoryID = "category_id"
        case title
    }
}
