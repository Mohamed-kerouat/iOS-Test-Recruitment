import XCTest
@testable import TheGoodCorner

@MainActor
final class APIClientTests: XCTestCase {
    func testBuildsURLWithQueryItems() async throws {
        let session = URLSession.stubbed(using: URLProtocolStub.self)
        let client = APIClient(baseURL: URL(string: "http://localhost:8080")!, session: session)
        URLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://localhost:8080/listings?page=1&limit=20")

            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data(#"{"total":0,"items":[],"limit":20,"has_more":false,"page":1}"#.utf8), response)
        }

        let queryItems: [URLQueryItem]? = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "20")
        ]

        _ = try await client.get(ListingsResponse.self, from: "/listings", queryItems: queryItems)
    }

    func testMapsTransportError() async {
        let session = URLSession.stubbed(using: URLProtocolStub.self)
        let client = APIClient(baseURL: URL(string: "http://localhost:8080")!, session: session)
        URLProtocolStub.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let queryItems: [URLQueryItem]? = nil
            _ = try await client.get(ListingsResponse.self, from: "/listings", queryItems: queryItems)
            XCTFail("Expected transport error")
        } catch let error as APIError {
            if case .transport = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected transport error, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }

    func testMapsServerErrorStatusCode() async {
        let session = URLSession.stubbed(using: URLProtocolStub.self)
        let client = APIClient(baseURL: URL(string: "http://localhost:8080")!, session: session)
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }

        do {
            let queryItems: [URLQueryItem]? = nil
            _ = try await client.get(ListingsResponse.self, from: "/listings", queryItems: queryItems)
            XCTFail("Expected server error")
        } catch let error as APIError {
            if case .server(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected server error, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }

    func testMapsDecodingError() async {
        let session = URLSession.stubbed(using: URLProtocolStub.self)
        let client = APIClient(baseURL: URL(string: "http://localhost:8080")!, session: session)
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data("not json".utf8), response)
        }

        do {
            let queryItems: [URLQueryItem]? = nil
            _ = try await client.get(ListingsResponse.self, from: "/listings", queryItems: queryItems)
            XCTFail("Expected decoding error")
        } catch let error as APIError {
            if case .decoding = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected decoding error, got \(error)")
            }
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }
}

private final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (Data, HTTPURLResponse))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private extension URLSession {
    static func stubbed(using urlProtocol: URLProtocol.Type) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [urlProtocol]
        return URLSession(configuration: configuration)
    }
}
