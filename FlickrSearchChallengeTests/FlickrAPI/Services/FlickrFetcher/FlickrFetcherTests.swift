import XCTest
@testable import FlickrSearchChallenge

class FlickrFetcherTests: XCTestCase {
    typealias SampleResult = Result<String, FlickrFetcher.Error>

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

    func test_whenBuilderFailsToBuildRequest_thenCallbackIsCalledWithRequestBuildError() {
        // GIVEN
        requestBuilder.urlRequestStub = nil
        var resultToTest: SampleResult?

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: SampleResult) in
            resultToTest = result
        }

        // THEN
        let expectedResult = SampleResult.failure(FlickrFetcher.Error.failedToBuildURLRequest)
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
        let expectedResult = SampleResult.failure(FlickrFetcher.Error.apiError(nil))
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
        let expectedResult = SampleResult.failure(FlickrFetcher.Error.noDataError)
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
        let expectedResult = SampleResult.failure(FlickrFetcher.Error.decodingError(nil))
        XCTAssertEqual(resultToTest, expectedResult)
    }

    func test_whenThereIsSuccessfulResponseWithValidData_thenItShouldBeDecodedAndReturnedInCallback() {
        // GIVEN
        let mockHTTPURLResponse = HTTPURLResponse.mocked()
        var resultToTest: Result<[String], FlickrFetcher.Error>?
        requestBuilder.urlRequestStub = .mocked()
        let sampleString = "some_value"
        let sampleJson = "[ \"\(sampleString)\" ]"
        let sampleData = sampleJson.data(using: .utf8)

        // WHEN
        fetcher.perform(SearchPhotosRequest.mocked()) { (result: Result<[String], FlickrFetcher.Error>) in
            resultToTest = result
        }
        urlSession.performFuncCheck.arguments?.1(sampleData, mockHTTPURLResponse, nil)

        // THEN
        let expectedResult = Result<[String], FlickrFetcher.Error>.success([sampleString])
        XCTAssertEqual(resultToTest, expectedResult)
    }
}
