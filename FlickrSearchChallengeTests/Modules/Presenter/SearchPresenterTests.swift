import XCTest
@testable import FlickrSearchChallenge

final class SearchPresenterTests: XCTestCase {
    typealias ResultCallback = (SearchedPhotosFetcher.Result) -> Void
    var mockFetcher: MockFetcher!
    var mockSearchedPhotosFetcher: MockSearchedPhotosFetcher!
    var mockView: MockSearchViewController!
    var presenter: SearchPresenter!

    override func setUp() {
        super.setUp()

        mockFetcher = MockFetcher(apiKey: "")
        mockSearchedPhotosFetcher = MockSearchedPhotosFetcher(fetcher: mockFetcher)
        mockView = MockSearchViewController()
        presenter = SearchPresenter(view: mockView,
                                    fetcher: mockFetcher,
                                    searchPhotosFetcher: mockSearchedPhotosFetcher)
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockSearchedPhotosFetcher = nil
        mockFetcher = nil

        super.tearDown()
    }

    func configurePresenterWithInitialLoad(_ initialLoadResult: SearchedPhotosFetcher.Result = .photos([]), paginator: Paginator = .mocked()) {
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", paginator)
        presenter.searchTextDidChange(text: searchString)
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(initialLoadResult)
        mockView.configureFuncCheck.reset()

    }

    // MARK: - viewDidLoad

    func test_whenViewDidLoadIsCalled_thenViewShouldBeConfiguredWithEmptyState() {
        // GIVEN

        // WHEN
        presenter.viewDidLoad()

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .empty))
    }

    // MARK: - searchTextDidChange

    func test_whenTextDidChangeToEmptyString_thenViewShouldBeConfiguredWithEmptyState() {
        // GIVEN

        // WHEN
        presenter.searchTextDidChange(text: "")

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .empty))
    }

    func test_whenTextDidChangeCalledWithLastSearchedString_thenConfigureConfigureShouldNotBeCalled() {
        // GIVEN
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = (searchString, .mocked())

        // WHEN
        presenter.searchTextDidChange(text: searchString)
        presenter.searchTextDidChange(text: searchString)
        presenter.searchTextDidChange(text: searchString)

        // THEN
        XCTAssertFalse(mockView.configureFuncCheck.wasCalled)
    }

    func test_whenTextDidChange_thenInitialLoadingStateShouldBeSetOnView() {
        // GIVEN
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", .mocked())

        // WHEN
        presenter.searchTextDidChange(text: searchString)

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .loading(.initial)))
    }

    func test_whenTextDidChange_whenSearchResultIsEmpty_thenViewShouldBeConfiguredWithNoResultState() {
        // GIVEN
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", .mocked())

        // WHEN
        presenter.searchTextDidChange(text: searchString)
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.empty)

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .noResult))
    }

    func test_whenTextDidChange_whenSearchRequestFailed_thenViewShouldBeConfiguredWithErrorState() {
        // GIVEN
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", .mocked())
        let error = APIError.noDataError

        // WHEN
        presenter.searchTextDidChange(text: searchString)
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.error(error))

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .error(error.localizedDescription)))
    }

    func test_whenTextDidChange_whenSearchRequestIsSuccessful_thenViewShouldBeConfiguredWithInitialLoadedState() {
        // GIVEN
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", .mocked())
        let photos = [Photo.mocked(), .mocked()]

        // WHEN
        presenter.searchTextDidChange(text: searchString)
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.photos(photos))

        // THEN
        XCTAssertEqual(presenter.cellModels.count, photos.count)
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .loaded(.initial)))
    }

    // MARK: - userDidScrollToBottom

    func test_whenUserDidScrollToBottomWithoutInitialLoad_thenNoViewConfigurationShouldBeSet() {
        // GIVEN

        // WHEN
        presenter.userDidScrollToBottom()

        // THEN
        XCTAssertFalse(mockView.configureFuncCheck.wasCalled)
    }

    func test_whenUserDidScrollToBottom_whenUserReachedLastPage_thenNoViewConfigurationShouldBeSet() {
        // GIVEN
        configurePresenterWithInitialLoad(paginator: .mocked(pageSize: 2, totalNumberOfPages: 1))

         // WHEN
         presenter.userDidScrollToBottom()

         // THEN
         XCTAssertFalse(mockView.configureFuncCheck.wasCalled)
    }

    func test_whenUserDidScrollToBottom_thenViewShouldBeConfiguredWithIterativeLoadingConfiguration() {
        // GIVEN
        configurePresenterWithInitialLoad()

        // WHEN
        presenter.userDidScrollToBottom()

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .loading(.iterative([]))))
    }

    func test_whenUserDidScrollToBottom_whenNextPageSearchResultIsEmpty_thenViewShouldBeConfiguredWithIterativeLoadedStateWithNoIndexPathsToInsert() {
        // GIVEN
        configurePresenterWithInitialLoad()

        // WHEN
        presenter.userDidScrollToBottom()
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.empty)

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .loaded(.iterative([]))))
    }

    func test_whenUserDidScrollToBottom_whenNextPageSearchRequestFailed_thenViewShouldBeConfiguredWithErrorState() {
        // GIVEN
        configurePresenterWithInitialLoad()
        let error = APIError.noDataError

        // WHEN
        presenter.userDidScrollToBottom()
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.error(error))

        // THEN
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .error(error.localizedDescription)))
    }

    func test_whenUserDidScrollToBottom_whenNextPageSearchRequestSucceed_thenViewShouldBeConfiguredWithIterativeLoadedStateWithRightIndexPaths() {
        // GIVEN
        let firstLoadPhotos = [Photo.mocked(), .mocked()]
        configurePresenterWithInitialLoad(.photos(firstLoadPhotos),
                                          paginator: Paginator(pageSize: 2,
                                                               totalNumberOfPages: 2))
        let nextPageLoadPhotos = [Photo.mocked(), .mocked()]

        // WHEN
        presenter.userDidScrollToBottom()
        mockView.configureFuncCheck.reset()
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.photos(nextPageLoadPhotos))

        // THEN
        let expectedIndexPaths = [IndexPath(row: 2, section: 0),
                                  IndexPath(row: 3, section: 0)]
        XCTAssertTrue(mockView.configureFuncCheck.wasCalled(with: .loaded(.iterative(expectedIndexPaths))))
        XCTAssertEqual(presenter.cellModels.count, firstLoadPhotos.count + nextPageLoadPhotos.count)
    }
}
