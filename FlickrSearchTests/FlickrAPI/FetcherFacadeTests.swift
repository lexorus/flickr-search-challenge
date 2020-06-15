import XCTest
import RxSwift
import RxBlocking
import PhotosAPI
import PhotosAPIMocks
@testable import FlickrSearch

final class FetcherFacadeTests: XCTestCase {
    var disposeBag = DisposeBag()
    var mockPhotosAPI: MockRxPhotosAPI!
    var mockImageStorage: MockImageStorage!
    var repository: ImageDataRepository!

    override func setUp() {
        super.setUp()

        mockPhotosAPI = MockRxPhotosAPI()
        mockImageStorage = MockImageStorage()
        repository = ImageDataRepository(imageFetcher: mockPhotosAPI,
                                         imageStorage: mockImageStorage)
    }

    override func tearDown() {
        repository = nil
        mockImageStorage = nil
        mockPhotosAPI = nil

        super.tearDown()
    }

    // MARK: getImageData

    func test_whenRequestingImageData_whenThereIsNoCachedData_thenTheRequestToAPIShouldBeSent() {
        // GIVEN
        let photo = Photo.mocked(id: "sampleID")

        // WHEN
        mockImageStorage.getImageDataStub = .error(ImageStorageError.notFound)
        _ = repository.getImageData(for: photo).toBlocking().materialize()

        // THEN
        XCTAssertTrue(mockPhotosAPI.getImageDataFuncCheck.wasCalled)
    }

    func test_whenRequestingImageData_whenThereIsNoCachedData_whenReqeustIsMade_thenTheResultShouldBeCached() {
        // GIVEN
        let samplePhotoID = "sampleID"
        let photo = Photo.mocked(id: samplePhotoID)
        let sampleCachedString = "sample"
        let sampleData = sampleCachedString.data(using: .utf8)!

        // WHEN
        mockImageStorage.getImageDataStub = .error(ImageStorageError.notFound)
        mockPhotosAPI.getImageDataStub = .just(sampleData)
        _ = repository.getImageData(for: photo).toBlocking().materialize()

        // THEN
        XCTAssertEqual(mockImageStorage.setImageDataFuncCheck.arguments?.0, sampleData)
        XCTAssertEqual(mockImageStorage.setImageDataFuncCheck.arguments?.1, samplePhotoID)
        XCTAssertTrue(mockImageStorage.setImageDataFuncCheck.wasCalled)
    }

    func test_whenRequestingImageData_whenThereIsCachedData_thenTheCachedDataShouldBeReturned() {
        // GIVEN
        let photo = Photo.mocked(id: "sampleID")
        let sampleCachedString = "sample"
        let cachedData = sampleCachedString.data(using: .utf8)!

        // WHEN
        mockImageStorage.getImageDataStub = .just(cachedData)
        let result = try? repository.getImageData(for: photo).toBlocking().first()

        // THEN
        XCTAssertEqual(result, cachedData)
        XCTAssertFalse(mockPhotosAPI.getImageDataFuncCheck.wasCalled)
    }
}
