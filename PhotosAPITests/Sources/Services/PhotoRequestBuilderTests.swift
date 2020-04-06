import XCTest
@testable import PhotosAPI

class PhotoRequestBuilderTests: XCTestCase {
    let builder = PhotoStringURLBuilder()

    func test_whenPhotoIsPassed_thenTheRightURLStringIsBuilt() {
        // GIVEN
        let photo = Photo(id: "id", title: "title", secret: "secret", server: "server", farm: 1)

        // WHEN
        let urlString = builder.urlString(for: photo)

        // THEN
        let expectedStringURL = "https://farm1.static.flickr.com/server/id_secret.jpg"
        XCTAssertEqual(urlString, expectedStringURL)
    }
}
