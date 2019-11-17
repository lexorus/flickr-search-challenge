import XCTest
@testable import FlickrSearchChallenge

class FlickrResponseTests: XCTestCase {
    func test_whenDecodingSuccessfulSearchPhotosRepsonse_thenDecodingSucceeds() {
        // GIVEN
        let successfulData = Data(testBundleFileName: "FlickrSearchPhotosSuccessResponse")
        
        // WHEN
        let decodedModel = try? JSONDecoder().decode(FlickrResponse<Photos>.self, from: successfulData!)

        // THEN
        let expectedPhoto1 = Photo(id: "49077689296",
                                   title: "Cat",
                                   secret: "6c458a1a76",
                                   server: "65535",
                                   farm: 66)
        let expectedPhoto2 = Photo(id: "49077374932",
                                   title: "Brown Tabby Cat",
                                   secret: "393d6f4586",
                                   server: "65535",
                                   farm: 66)
        let expectedPhotosPage = PhotosPage(pageNumber: 1,
                                            totalNumberOfPages: 91196,
                                            itemsPerPage: 2,
                                            totalItems: "182391",
                                            photos: [expectedPhoto1, expectedPhoto2])
        let expectedResponse = FlickrResponse(result: .success(Photos(photos: expectedPhotosPage)), status: .success)
        XCTAssertEqual(decodedModel, expectedResponse)
    }

    func test_whenDecodingFailureSearchPhotosResponse_thenDecodingSucceeds() {
        // GIVEN
        let failureData = Data(testBundleFileName: "FlickrSearchPhotosFailureResponse")

        // WHEN
        let decodedModel = try? JSONDecoder().decode(FlickrResponse<Photos>.self, from: failureData!)

        // THEN
        let expectedError = FlickrResponse<Photos>.Error(code: 112,
                                                 message: "Method \"flickr.photos.searchr\" not found")
        let expectedResponse = FlickrResponse(result: Result<Photos, FlickrResponse.Error>.failure(expectedError), status: .failure)
        XCTAssertEqual(decodedModel, expectedResponse)
    }
}
