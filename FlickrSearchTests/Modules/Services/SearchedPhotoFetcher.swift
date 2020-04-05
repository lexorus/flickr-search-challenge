import XCTest
@testable import FlickrSearch

final class SearchedPhotoFetcher: XCTestCase {
    typealias ResultCallback = (SearchedPhotosFetcher.Result) -> Void
    var mockFetcher: MockFetcher!
    var searchedPhotosFetcher: SearchedPhotosFetcher!

    override func setUp() {
        super.setUp()

        mockFetcher = MockFetcher(apiKey: "")
        searchedPhotosFetcher = SearchedPhotosFetcher(fetcher: mockFetcher)
    }

    override func tearDown() {
        searchedPhotosFetcher = nil
        mockFetcher = nil

        super.tearDown()
    }

    func prepareSearchedPhotosFetcher(text: String = "text",
                                      photosPage: PhotosPage = .mocked(),
                                      callback: @escaping ResultCallback = { _ in }) {
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(photosPage))
    }

    // MARK: - cancelCurrentRequest

    func test_whenCancellingCurrentRequest_thenSearchPhotosInfoShouldBeCleared() {
        // GIVEN
        let text = "search text"
        let pageSize: UInt = 2
        let numberOfPages: UInt = 2
        let stubPhotosPage = PhotosPage.mocked(totalNumberOfPages: numberOfPages,
                                               itemsPerPage: pageSize)
        searchedPhotosFetcher.loadFirstPage(for: text, callback: { _ in })
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(stubPhotosPage))

        // WHEN
        searchedPhotosFetcher.cancelCurrentRequest()

        // THEN
        XCTAssertNil(searchedPhotosFetcher.searchPhotosInfo)
    }

    func test_whenCancellingCurrentRequest_thenCurrentReqeustShouldBeCanceledAndNullitied() {
        // GIVEN
        let text = "search text"
        let pageSize: UInt = 2
        let numberOfPages: UInt = 2
        let stubPhotosPage = PhotosPage.mocked(totalNumberOfPages: numberOfPages,
                                               itemsPerPage: pageSize)
        let mockCancellable = MockCancellable()
        mockFetcher.getPhotosCancellableStub = mockCancellable
        searchedPhotosFetcher.loadFirstPage(for: text, callback: { _ in })
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(stubPhotosPage))

        // WHEN
        searchedPhotosFetcher.cancelCurrentRequest()

        // THEN
        XCTAssertTrue(mockCancellable.cancelFuncCheck.wasCalled)
        XCTAssertNil(searchedPhotosFetcher.currentRequest)
    }

    // MARK: - loadFirstPage

    func test_whenLoadFirstPageIsCalled_whenGetPhotosSucceeds_thenTheRightSearchPhotosInfoIsSet() {
        // GIVEN
        let text = "search text"
        let callback: (SearchedPhotosFetcher.Result) -> Void = { _ in }
        let pageSize: UInt = 2
        let numberOfPages: UInt = 2
        let stubPhotosPage = PhotosPage.mocked(totalNumberOfPages: numberOfPages,
                                               itemsPerPage: pageSize)

        // WHEN
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(stubPhotosPage))
        let info = searchedPhotosFetcher.searchPhotosInfo

        // THEN
        XCTAssertEqual(info?.searchString, text)
        let expectedPaginator = Paginator(pageSize: pageSize,
                                          totalNumberOfPages: numberOfPages)
        XCTAssertEqual(info?.paginator, expectedPaginator)
    }

    func test_whenLoadFirstPageIsCalled_whenGetPhotosSucceeds_whenPhotosAreEmpty_thenCallbackIsCalledWithEmptyResult() {
        // GIVEN
        let text = "search text"
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        let stubPhotosPage = PhotosPage.mocked(photos: [])

        // WHEN
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(stubPhotosPage))

        // THEN
        XCTAssertEqual(callbackResult, .empty)
    }

    func test_whenLoadFirstPage_whenGetPhotosSucceeds_whenPhotosAreNotEmpty_thenCallbackIsCalledWithPhotosResult() {
        // GIVEN
        let text = "search text"
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        let photos = [Photo.mocked()]
        let stubPhotosPage = PhotosPage.mocked(photos: photos)

        // WHEN
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(stubPhotosPage))

        // THEN
        XCTAssertEqual(callbackResult, .photos(photos))
    }

    func test_whenLoadFirstPageIsCalled_whenGetPhotosFails_thenCallbackIsCalledWithErrorResult() {
        // GIVEN
        let text = "search text"
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        let error = APIError.noDataError

        // WHEN
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.failure(error))

        // THEN
        XCTAssertEqual(callbackResult, .error(error))
    }

    func test_whenLoadFirstPageIsCalled_whenThereIsAnActiveRequest_thenTheActiveRequestShouldBeCancelled() {
        // GIVEN
        let text = "search text"
        let callback: (SearchedPhotosFetcher.Result) -> Void = { _ in }

        // WHEN
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)
        searchedPhotosFetcher.loadFirstPage(for: text, callback: callback)

        // THEN
        XCTAssertTrue(mockFetcher.getPhotosCancellableStub.cancelFuncCheck.wasCalled)
    }

    // MARK: - loadNextPage

    func test_whenLoadNextPageIsCalled_whenThereIsNoNextPage_thenCallbackShouldNotBeCalledWithAnyResult() {
        // GIVEN
        let stubPhotosPage = PhotosPage.mocked(pageNumber: 1, totalNumberOfPages: 1)
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        prepareSearchedPhotosFetcher(photosPage: stubPhotosPage)

        // WHEN
        searchedPhotosFetcher.loadNextPage(callback: callback)

        // THEN
        XCTAssertNil(callbackResult)
    }

    func test_whenLoadNextPageIsCalled_whenGetPhotosFails_thenCallbackIsCalledWithErrorResult() {
        // GIVEN
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        prepareSearchedPhotosFetcher()
        let error = APIError.noDataError

        // WHEN
        searchedPhotosFetcher.loadNextPage(callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.failure(error))

        // THEN
        XCTAssertEqual(callbackResult, .error(error))
    }

    func test_whenLoadNextPageIsCalled_whenGetPhotosSucceeds_whenPhotosAreEmpty_thenCallbackIsCalledWithEmptyResult() {
        // GIVEN
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        prepareSearchedPhotosFetcher()

        // WHEN
        searchedPhotosFetcher.loadNextPage(callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(.mocked(photos: [])))

        // THEN
        XCTAssertEqual(callbackResult, .empty)
    }

    func test_whenLoadNextPage_whenGetPhotosSucceeds_whenPhotosAreNotEmpty_thenCallbackIsCalledWithEmptyResult() {
        // GIVEN
        var callbackResult: SearchedPhotosFetcher.Result?
        let callback: (SearchedPhotosFetcher.Result) -> Void = {
            callbackResult = $0
        }
        prepareSearchedPhotosFetcher()
        let photos = [Photo.mocked()]

        // WHEN
        searchedPhotosFetcher.loadNextPage(callback: callback)
        mockFetcher.getPhotosFuncCheck.arguments?.3(.success(.mocked(photos: photos)))

        // THEN
        XCTAssertEqual(callbackResult, .photos(photos))
    }
}
