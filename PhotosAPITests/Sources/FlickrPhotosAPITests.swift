import XCTest
import MicroNetworkMocks
@testable import PhotosAPI

final class FlickrPhotosAPITests: XCTestCase {
    typealias SampleResult = Result<String, APIError>

    let sampleAPIKey = "sample_api_key"
    var mockRequestBuilder: MockRequestBuilder!
    var mockNetwork: MockNetwork!
    var fetcher: FlickrPhotosAPI!

    override func setUp() {
        super.setUp()

        mockRequestBuilder = MockRequestBuilder(apiKey: sampleAPIKey)
        mockNetwork = MockNetwork()
        fetcher = FlickrPhotosAPI(apiKey: sampleAPIKey,
                                network: mockNetwork,
                                requestBuilder: { _ in mockRequestBuilder })
    }

    override func tearDown() {
        fetcher = nil
        mockNetwork = nil
        mockRequestBuilder = nil

        super.tearDown()
    }

    // MARK: - perform(request:callback:)

    func test_whenBuilderFailsToBuildRequest_thenCallbackIsCalledWithRequestBuildError() {
        // GIVEN
        mockRequestBuilder.urlRequestStub = nil

        // WHEN
        var resultToTest: Result<PhotosPage, APIError>?
        _ = fetcher.getPhotos(query: "query", pageNumber: 1, pageSize: 1) { result in
            resultToTest = result
        }

        // THEN
        let expectedResult = Result<PhotosPage, APIError>.failure(.failedToBuildURLRequest)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenThereIsSuccessfulResponseWithValidData_thenItShouldBeDecodedAndReturnedInCallback() {
        // GIVEN
        mockRequestBuilder.urlRequestStub = .mocked()
        let sampleData = Data(testBundleFileName: "FlickrSearchPhotosSuccessResponse")!

        // WHEN
        var resultToTest: Result<PhotosPage, APIError>?
        _ = fetcher.getPhotos(query: "query", pageNumber: 1, pageSize: 1) { result in
            resultToTest = result
        }
        mockNetwork.dataTaskCompletion?(.success(sampleData))

        // THEN
        guard  let decodedPhotosPage = try? JSONDecoder().decode(FlickrResponse<Photos>.self, from: sampleData),
            let photos = try? decodedPhotosPage.result.get().photos else {
                return XCTFail("Failed to decode fixture.")
        }
        let expectedResult = Result<PhotosPage, APIError>.success(photos)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    // MARK: - getData(from:callback)

    func test_whenGetDataBuilderFailsToBuildRequest_thenCallbackIsCalledWithRequestBuildError() {
        // GIVEN

        // WHEN
        var resultToTest: Result<Data, APIError>?
        _ = fetcher.getImageData(for: .mocked(id: "??%%")) {
            resultToTest = $0
        }

        // THEN
        let expectedResult = Result<Data, APIError>.failure(.failedToBuildURLRequest)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenGetDataSucceedsWithValidData_thenDataIsReturnedInCallback() {
        // GIVEN
        let sampleData = "sample".data(using: .utf8)!

        // WHEN
        var resultToTest: Result<Data, APIError>?
        _ = fetcher.getImageData(for: .mocked()) {
            resultToTest = $0
        }
        mockNetwork.dataTaskCompletion?(.success(sampleData))

        // THEN
        let expectedResult = Result<Data, APIError>.success(sampleData)
        XCTAssertEqual(resultToTest, expectedResult)
    }
}
