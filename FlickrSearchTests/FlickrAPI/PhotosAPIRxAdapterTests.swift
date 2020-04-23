import XCTest
import RxSwift
import PhotosAPI
import PhotosAPIMocks
import RxBlocking
@testable import FlickrSearch

final class PhotosAPIRxAdapterTests: XCTestCase {
    var disposeBag: DisposeBag!
    var mockAPI: MockPhotosAPI!
    var rxAPI: PhotosAPIRxAdapter!

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()
        mockAPI = MockPhotosAPI()
        rxAPI = PhotosAPIRxAdapter(photosAPI: mockAPI)
    }

    override func tearDown() {
        rxAPI = nil
        mockAPI = nil
        disposeBag = nil

        super.tearDown()
    }

    // MARK: - getPhotos
    func test_whenGetPhotosAPIWillFail_thenSingleErrorEventShouldBeEmitted() {
        // GIVEN
        var response: PhotosPage?
        var error: Error?
        rxAPI.getPhotos(query: "query", pageNumber: 0, pageSize: 0)
            .subscribe(onSuccess: { response = $0 },
                       onError: { error = $0 })
            .disposed(by: disposeBag)

        // WHEN
        let apiError = APIError.noDataError
        mockAPI.getPhotosFuncCheck.arguments?.3(.failure(apiError))

        // THEN
        XCTAssertNil(response)
        XCTAssertEqual(error as? APIError, apiError)
    }

    func test_whenGetPhotosAPIFechesPhotosSuccesfully_thenSingleSuccessEventShouldBeEmitted() {
        // GIVEN
        var response: PhotosPage?
        var error: Error?
        rxAPI.getPhotos(query: "query", pageNumber: 0, pageSize: 0)
            .subscribe(onSuccess: { response = $0 },
                       onError: { error = $0 })
            .disposed(by: disposeBag)

        // WHEN
        let apiResult = PhotosPage.mocked()
        mockAPI.getPhotosFuncCheck.arguments?.3(.success(apiResult))

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual(response, apiResult)
    }

    func test_whenGetPhotosAPICallbackIsCalledMultipleTimes_thenOnlyOneEventShouldBeEmitted() {
        // GIVEN
        var response: PhotosPage?
        var error: Error?
        rxAPI.getPhotos(query: "query", pageNumber: 0, pageSize: 0)
            .subscribe(onSuccess: { response = $0 },
                       onError: { error = $0 })
            .disposed(by: disposeBag)

        // WHEN
        let firstAPIResponse = PhotosPage.mocked()
        mockAPI.getPhotosFuncCheck.arguments?.3(.success(firstAPIResponse))
        let secondAPIResponse = PhotosPage.mocked(pageNumber: 2)
        mockAPI.getPhotosFuncCheck.arguments?.3(.success(secondAPIResponse))

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual(response, firstAPIResponse)
    }

    // MARK: - getImageData
    func test_whengetImageDataWillFail_thenSingleErrorEventShouldBeEmitted() {
        // GIVEN
        var response: Data?
        var error: Error?
        rxAPI.getImageData(for: .mocked())
            .subscribe(onSuccess: { response = $0 },
                       onError: { error = $0 })
            .disposed(by: disposeBag)

        // WHEN
        let apiError = APIError.noDataError
        mockAPI.getImageDataFuncCheck.arguments?.1(.failure(apiError))

        // THEN
        XCTAssertNil(response)
        XCTAssertEqual(error as? APIError, apiError)
    }

    func test_whengetImageDataFechesPhotosSuccesfully_thenSingleSuccessEventShouldBeEmitted() {
        // GIVEN
        var response: Data?
        var error: Error?
        rxAPI.getImageData(for: .mocked())
            .subscribe(onSuccess: { response = $0 },
                       onError: { error = $0 })
            .disposed(by: disposeBag)

        // WHEN
        let apiResult = Data()
        mockAPI.getImageDataFuncCheck.arguments?.1(.success(apiResult))

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual(response, apiResult)
    }
}
