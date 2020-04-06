import XCTest
import PhotosAPI
@testable import FlickrSearch

final class FetcherFacadeTests: XCTestCase {
    var mockFlickrFetcher: MockFlickrFetcher<PhotosPage>!
    var mockImageCacher: MockImageCacher!
    var fetcher: Fetcher!

    override func setUp() {
        super.setUp()

        mockFlickrFetcher = MockFlickrFetcher()
        mockImageCacher = MockImageCacher()
        fetcher = Fetcher(apiKey: "key",
                          flickrFetcher: mockFlickrFetcher,
                          imageCacher: mockImageCacher)
    }

    override func tearDown() {
        fetcher = nil
        mockImageCacher = nil
        mockFlickrFetcher = nil

        super.tearDown()
    }

    // MARK: getImageData

    func test_whenRequestingImageData_whenThereIsNoCachedData_thenTheRequestToAPIShouldBeSent() {
        // GIVEN
        let photo = Photo.mocked(id: "sampleID")

        // WHEN
        fetcher.getImageData(for: photo) { _ in }
        mockImageCacher.getImageDataFuncCheck.arguments?.1(nil)

        // THEN
        XCTAssertTrue(mockFlickrFetcher.getImageDataFuncCheck.wasCalled)
    }

    func test_whenRequestingImageData_whenThereIsNoCachedData_whenReqeustIsMade_thenTheResultShouldBeCached() {
        // GIVEN
        let samplePhotoID = "sampleID"
        let photo = Photo.mocked(id: samplePhotoID)
        let sampleCachedString = "sample"
        let sampleData = sampleCachedString.data(using: .utf8)!

        // WHEN
        fetcher.getImageData(for: photo) { _ in }
        mockImageCacher.getImageDataFuncCheck.arguments?.1(nil)
        mockFlickrFetcher.getImageDataFuncCheck.arguments?.1(.success(sampleData))

        // THEN
        XCTAssertEqual(mockImageCacher.setImageDataFuncCheck.arguments?.0, sampleData)
        XCTAssertEqual(mockImageCacher.setImageDataFuncCheck.arguments?.1, samplePhotoID)
        XCTAssertTrue(mockImageCacher.setImageDataFuncCheck.wasCalled)
    }

    func test_whenRequestingImageData_whenThereIsCachedData_thenTheCachedDataShouldBeReturned() {
        // GIVEN
        let photo = Photo.mocked(id: "sampleID")
        let sampleCachedString = "sample"
        let cachedData = sampleCachedString.data(using: .utf8)!
        var result: Result<Data, APIError>!

        // WHEN
        fetcher.getImageData(for: photo) { result = $0 }
        mockImageCacher.getImageDataFuncCheck.arguments?.1(cachedData)

        // THEN
        let expectedResult = Result<Data, APIError>.success(cachedData)
        XCTAssertEqual(result, expectedResult)
        XCTAssertFalse(mockFlickrFetcher.getImageDataFuncCheck.wasCalled)
    }

}
