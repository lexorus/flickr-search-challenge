import XCTest
import PhotosAPI
import RxSwift
import RxTest
import RxBlocking
@testable import FlickrSearch

final class SearchViewModelTests: XCTestCase {
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var mockFetcher: MockFetcher!
    var mockSearchedPhotosFetcher: MockSearchedPhotosFetcher!
    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()

        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        mockFetcher = MockFetcher(apiKey: "")
        mockSearchedPhotosFetcher = MockSearchedPhotosFetcher(fetcher: mockFetcher)
        viewModel = SearchViewModel(fetcher: mockFetcher,
                                    searchPhotosFetcher: mockSearchedPhotosFetcher)
    }

    override func tearDown() {
        viewModel = nil
        mockSearchedPhotosFetcher = nil
        mockFetcher = nil

        super.tearDown()
    }

    private func configureViewModelWithInitialLoad(_ initialLoadResult: SearchedPhotosFetcher.Result = .photos([]),
                                                   paginator: Paginator = .mocked()) {
        let searchString = "query"
        mockSearchedPhotosFetcher.searchPhotosInfo = ("another search string", paginator)
        viewModel.searchText.onNext(searchString)
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(initialLoadResult)
    }

    private func newViewStatesObserver(skipStates: Int = 1,
                                       scheduler: TestScheduler? = nil)
        -> TestableObserver<SearchViewController.State> {
            let states = (scheduler ?? testScheduler).createObserver(SearchViewController.State.self)
            viewModel.viewState
                .asDriver {
                    XCTFail("\($0)")
                    return .just(.empty)
                }
                .skip(skipStates)
                .drive(states)
                .disposed(by: disposeBag)

            return states
    }

    // MARK: - searchText

    func test_whenTextDidChangeToEmptyString_thenViewStateShouldBecomeEmpty() {
        // GIVEN
        let searchString = String.empty

        // WHEN
        viewModel.searchText.onNext(searchString)

        // THEN
        let expectedViewState = SearchViewController.State.empty
        XCTAssertEqual(try? viewModel.viewState.value(), expectedViewState)
    }

    func test_whenTextDidChangeToEmptyString_thenPhotosFetcherShouldCancelAnyActiveRequests() {
        // GIVEN
        let searchString = String.empty

        // WHEN
        viewModel.searchText.onNext(searchString)

        // THEN
        XCTAssertTrue(mockSearchedPhotosFetcher.cancelCurrentRequestFuncCheck.wasCalled)
    }

    func test_whenTextDidChangeWithSameQuery_thenViewStateChangeShouldNotBeCalled() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()

        // WHEN
        testScheduler.createColdObservable([.next(0, searchQuery)])
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        testScheduler.start()

        // THEN
        XCTAssertTrue(states.events.isEmpty)
    }

    func test_whenTextDidChangeToAnotherQuery_thenViewStateSholdChangeToInitialLoading() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()

        // WHEN
        let newSearchQuery = "newQuery"
        testScheduler.createColdObservable([.next(0, newSearchQuery)])
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.loading(.initial)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenTextDidChange_whenSearchResultIsEmpty_thenViewStateShouldBeNoResult() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()

        // WHEN
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.empty)
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.noResult
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenTextDidChange_whenSearchRequestFail_thenViewStateShouldBeError() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()
        let error = APIError.noDataError

        // WHEN
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.error(error))
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.error(error.description)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenTextDidChange_whenSearchRequestSucceeds_thenViewStateShouldBeInitialLoaded() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()

        // WHEN
        mockSearchedPhotosFetcher.loadFirstPageFuncCheck.arguments?.1(.photos([]))
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.initial)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    // MARK: - isScrolledToBottom

    func test_whenUserDidScrollToBottom_whenNoContentWasLoadedYet_thenNoNewViewStatesShouldAppear() {
        // GIVEN
        let states = newViewStatesObserver()

        // WHEN
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        testScheduler.start()

        // THEN
        XCTAssertTrue(states.events.isEmpty)
    }

    func test_whenUserDidScrollToBottomW_whenUserReachedLastPage_thenNoNewViewStatesShouldAppear() {
        // GIVEN
        configureViewModelWithInitialLoad(paginator: .mocked(pageSize: 2, totalNumberOfPages: 1))
        let states = newViewStatesObserver()

        // WHEN
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        testScheduler.start()

        // THEN
        XCTAssertTrue(states.events.isEmpty)
    }

    func test_whenUserDidScrollToBottom_thenViewStateShouldBeIterativeLoading() {
        // GIVEN
        configureViewModelWithInitialLoad()
        let states = newViewStatesObserver()

        // WHEN
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.loading(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenUserDidScrollToBottom_whenNextPageResultIsEmpty_thenViewStateShouldBeIterativeLoaded() {
        // GIVEN
        configureViewModelWithInitialLoad()
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        let states = newViewStatesObserver(skipStates: 2)
        testScheduler.start()

        // WHEN
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.empty)

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenUserDidScrollToBottom_whenNextPageRequestFail_thenViewStateShouldBeIterativeLoaded() {
        // GIVEN
        configureViewModelWithInitialLoad()
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        let states = newViewStatesObserver(skipStates: 2)
        testScheduler.start()

        // WHEN
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.error(.noDataError))

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenUserDidScrollToBottom_whenNextPageRequestSucceeds_thenViewStateShouldBeIterativeLoaded() {
        // GIVEN
        configureViewModelWithInitialLoad()
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        let states = newViewStatesObserver(skipStates: 2)
        testScheduler.start()

        // WHEN
        mockSearchedPhotosFetcher.loadNextPageFuncCheck.arguments?(.photos([]))

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }
}
