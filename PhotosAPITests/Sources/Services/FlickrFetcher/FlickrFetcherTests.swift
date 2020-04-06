import XCTest
@testable import PhotosAPI

class FlickrFetcherTests: XCTestCase {
    typealias SampleResult = Result<String, APIError>

    let sampleAPIKey = "sample_api_key"
    var requestBuilder: MockRequestBuilder!
    var urlSession: MockURLSession!
    var fetcher: FlickrFetcher!

    override func setUp() {
        super.setUp()

        requestBuilder = MockRequestBuilder(apiKey: sampleAPIKey)
        urlSession = MockURLSession()
        fetcher = FlickrFetcher(apiKey: sampleAPIKey,
                                urlSession: urlSession,
                                requestBuilder: { _ in requestBuilder })
    }

    override func tearDown() {
        fetcher = nil
        urlSession = nil
        requestBuilder = nil

        super.tearDown()
    }

    // MARK: - perform(request:callback:)

    func test_whenBuilderFailsToBuildRequest_thenCallbackIsCalledWithRequestBuildError() {
        // GIVEN
        requestBuilder.urlRequestStub = nil
        var resultToTest: SampleResult?

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }

        // THEN
        let expectedResult = SampleResult.failure(.failedToBuildURLRequest)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenResponseStatusCodeIsNotSuccessful_thenTheCallbackShouldBeCalledWithAPIError() {
        // GIVEN
        let mockHTTPURLResponse = HTTPURLResponse.mocked(statusCode: 400)
        var resultToTest: SampleResult?
        requestBuilder.urlRequestStub = .mocked()

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }
        urlSession.performFuncCheck.arguments?.1(nil, mockHTTPURLResponse, nil)

        // THEN
        let expectedResult = SampleResult.failure(.apiError(nil))
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenThereIsNoDataInResponse_thenTheCallbackShouldBeCalledWithNoDataError() {
        // GIVEN
        let mockHTTPURLResponse = HTTPURLResponse.mocked()
        var resultToTest: SampleResult?
        requestBuilder.urlRequestStub = .mocked()

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }
        urlSession.performFuncCheck.arguments?.1(nil, mockHTTPURLResponse, nil)

        // THEN
        let expectedResult = SampleResult.failure(.noDataError)
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenResponseDataCannotBeDecoded_thenTheCallbackShouldBeCalledWithDecodingError() {
        // GIVEN
        let mockHTTPURLResponse = HTTPURLResponse.mocked()
        var resultToTest: SampleResult?
        requestBuilder.urlRequestStub = .mocked()

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }
        urlSession.performFuncCheck.arguments?.1(Data(), mockHTTPURLResponse, nil)

        // THEN
        let expectedResult = SampleResult.failure(.decodingError(nil))
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenThereIsSuccessfulResponseWithValidData_thenItShouldBeDecodedAndReturnedInCallback() {
        // GIVEN
        let mockHTTPURLResponse = HTTPURLResponse.mocked()
        var resultToTest: Result<[String], APIError>?
        requestBuilder.urlRequestStub = .mocked()
        let sampleString = "some_value"
        let sampleJson = "[ \"\(sampleString)\" ]"
        let sampleData = sampleJson.data(using: .utf8)

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: Result<[String], APIError>) in
            resultToTest = result
        }
        urlSession.performFuncCheck.arguments?.1(sampleData, mockHTTPURLResponse, nil)

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
        urlSession.performFuncCheck.arguments?.1(sampleData, HTTPURLResponse.mocked(), nil)

        // THEN
        let expectedResult = Result<Data, APIError>.success(sampleData)
        XCTAssertEqual(resultToTest, expectedResult)
    }

}
