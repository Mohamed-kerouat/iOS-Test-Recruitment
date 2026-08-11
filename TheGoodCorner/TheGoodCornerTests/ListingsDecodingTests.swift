import XCTest
@testable import TheGoodCorner

@MainActor
final class ListingsDecodingTests: XCTestCase {
    func testDecodesListingsResponseEnvelope() throws {
        let json = """
        {
          "total": 1,
          "items": [
            {
              "id": 1547408955,
              "is_urgent": true,
              "images_url": {
                "small": "/images/ad-small/example.jpg",
                "thumb": "/images/ad-thumb/example.jpg"
              },
              "creation_date": "2019-11-06T11:22:35Z",
              "price": 10,
              "description": "A description",
              "category_id": 7,
              "title": "A title"
            }
          ],
          "limit": 20,
          "has_more": true,
          "page": 1
        }
        """

        let response = try decode(ListingsResponse.self, from: json)
        XCTAssertEqual(response.total, 1)
        XCTAssertEqual(response.limit, 20)
        XCTAssertEqual(response.hasMore, true)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.title, "A title")
    }

    func testDecodesListingWithMissingImageData() throws {
        let json = """
        {
          "id": 1701863965,
          "is_urgent": false,
          "images_url": {},
          "creation_date": "2019-11-05T15:56:45Z",
          "price": 37,
          "description": "A description",
          "category_id": 5,
          "title": "Another title"
        }
        """

        let listing = try decode(Listing.self, from: json)
        XCTAssertEqual(listing.id, 1701863965)
        XCTAssertEqual(listing.isUrgent, false)
        XCTAssertEqual(listing.imagesURL?.small, nil)
        XCTAssertEqual(listing.imagesURL?.thumb, nil)
        XCTAssertEqual(listing.categoryID, 5)
        XCTAssertEqual(listing.title, "Another title")
    }

    func testDecodesCategory() throws {
        let json = """
        {
          "id": 8,
          "name": "Multimedia"
        }
        """

        let category = try decode(Category.self, from: json)
        XCTAssertEqual(category.id, 8)
        XCTAssertEqual(category.name, "Multimedia")
    }

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
