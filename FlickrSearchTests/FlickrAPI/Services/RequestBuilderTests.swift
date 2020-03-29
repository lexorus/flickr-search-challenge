import XCTest
@testable import FlickrSearch

class RequestBuilderTests: XCTestCase {
    let apiKey = "some_api_key"
    var requestBuilder: RequestBuilder {
        RequestBuilder(apiKey: apiKey)
    }

    func test_whenURLRequestIsBuiltUsingFlickrRequest_thenRightURLRequestIsReturned() {
        // GIVEN
        let flickrRequest = SearchPhotosRequest(query: "query", page: 1, pageSize: 2)

        // WHEN
        let urlRequest = requestBuilder.urlRequest(from: flickrRequest)

        // THEN
        let expectedURLString = "https://api.flickr.com/services/rest/?api_key=some_api_key&format=json&nojsoncallback=1&safe_search=1&per_page=2&page=1&method=flickr.photos.search&text=query"
        XCTAssertEqual(urlRequest?.url?.absoluteString, expectedURLString)
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.get.rawValue)
    }
}
