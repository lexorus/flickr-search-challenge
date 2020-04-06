import XCTest
import MicroNetworkMocks
@testable import PhotosAPI

class FlickrFetcherTests: XCTestCase {
    typealias SampleResult = Result<String, APIError>

    let sampleAPIKey = "sample_api_key"
    var mockRequestBuilder: MockRequestBuilder!
    var mockNetwork: MockNetwork!
    var fetcher: FlickrFetcher!

    override func setUp() {
        super.setUp()

        mockRequestBuilder = MockRequestBuilder(apiKey: sampleAPIKey)
        mockNetwork = MockNetwork()
        fetcher = FlickrFetcher(apiKey: sampleAPIKey,
                                urlSession: mockNetwork,
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
        var resultToTest: SampleResult?

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }

        // THEN
        let expectedResult = SampleResult.failure(.failedToBuildURLRequest)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenThereIsSuccessfulResponseWithValidData_thenItShouldBeDecodedAndReturnedInCallback() {
        // GIVEN
        var resultToTest: Result<[String], APIError>?
        mockRequestBuilder.urlRequestStub = .mocked()
        let sampleString = "some_value"
        let sampleJson = "[ \"\(sampleString)\" ]"
        let sampleData = sampleJson.data(using: .utf8)!

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: Result<[String], APIError>) in
            resultToTest = result
        }
        mockNetwork.dataTaskCompletion?(.success(sampleData))
        
        // THEN
        let expectedResult = Result<[String], APIError>.success([sampleString])
        XCTAssertEqual(resultToTest, expectedResult)
    }

    // MARK: - getData(from:callback)

    func test_whenGetDataBuilderFailsToBuildRequest_thenCallbackIsCalledWithRequestBuildError() {
        // GIVEN
        var resultToTest: Result<Data, APIError>?

        // WHEN
        fetcher.getData(from: "") {
            resultToTest = $0
        }

        // THEN
        let expectedResult = Result<Data, APIError>.failure(.failedToBuildURLRequest)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenGetDataSucceedsWithValidData_thenDataIsReturnedInCallback() {
        // GIVEN
        var resultToTest: Result<Data, APIError>?
        let sampleData = "sample".data(using: .utf8)!

        // WHEN
        fetcher.getData(from: "sample_url.com") {
            resultToTest = $0
        }
        mockNetwork.dataTaskCompletion?(.success(sampleData))

        // THEN
        let expectedResult = Result<Data, APIError>.success(sampleData)
        XCTAssertEqual(resultToTest, expectedResult)
    }

}
