import XCTest
import PhotosAPI
import PhotosAPIMocks
import RxSwift
import RxTest
import RxBlocking
@testable import FlickrSearch

final class SearchViewModelTests: XCTestCase {
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var mockPhotosAPI: MockPhotosAPI!
    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()

        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        mockPhotosAPI = MockPhotosAPI()
        viewModel = SearchViewModel(photosAPI: mockPhotosAPI)
    }

    override func tearDown() {
        viewModel = nil
        mockPhotosAPI = nil

        super.tearDown()
    }

    private func configureViewModelWithInitialLoad(_ initialLoadResult: Result<PhotosPage, APIError> = .success(.mocked(photos: [.mocked()]))) {
        let searchString = "query"
        viewModel.searchText.onNext(searchString)
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(initialLoadResult)
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
                .distinctUntilChanged()
                .drive(states)
                .disposed(by: disposeBag)

            return states
    }

    // MARK: - searchText

    func test_whenTextDidChangeToEmptyString_thenViewStateShouldBecomeEmpty() {
        // GIVEN
        let initialText = "query"
        viewModel.searchText.onNext(initialText)
        let emptyText = String.empty

        // WHEN
        viewModel.searchText.onNext(emptyText)

        // THEN
        let expectedViewState = SearchViewController.State.empty
        XCTAssertEqual(try? viewModel.viewState.value(), expectedViewState)
    }

    func test_whenTextDidChangeToEmptyString_thenPhotosFetcherShouldCancelAnyActiveRequests() {
        // GIVEN
        let initialText = "query"
        viewModel.searchText.onNext(initialText)
        let emptyText = String.empty

        // WHEN
        viewModel.searchText.onNext(emptyText)

        // THEN
        XCTAssertTrue(mockPhotosAPI.getPhotosStub.cancelFuncCheck.wasCalled)
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
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.success(.init(pageNumber: 0,
                                                                     totalNumberOfPages: 0,
                                                                     itemsPerPage: 0,
                                                                     totalItems: "0",
                                                                     photos: [])))
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.noResult
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenTextDidChange_whenSearchRequestFail_thenViewStateShouldBeEmptyWithError() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()
        let error = APIError.noDataError

        // WHEN
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.failure(error))
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.error(error.description)
        XCTAssertEqual(states.events, [.next(0, .empty), .next(0, expectedViewState)])
    }

    func test_whenTextDidChange_whenSearchRequestSucceeds_thenViewStateShouldBeInitialLoaded() {
        // GIVEN
        let searchQuery = "query"
        viewModel.searchText.onNext(searchQuery)
        let states = newViewStatesObserver()

        // WHEN
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.success(.mocked(photos: [.mocked()])))
        testScheduler.start()

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.initial)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    // MARK: - isScrolledToBottom

    func test_whenUserDidScrollToBottom_whenUserReachedLastPage_thenViewStateShouldNotChange() {
        // GIVEN
        configureViewModelWithInitialLoad(.success(.mocked(pageNumber: 1, totalNumberOfPages: 1)))
        let states = newViewStatesObserver()

        // WHEN
        let currentViewState = try! viewModel.viewState.value()
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        testScheduler.start()

        // THEN
        XCTAssertEqual(states.events.last?.value, .next(currentViewState))
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
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.success(.mocked(photos: [])))

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }

    func test_whenUserDidScrollToBottom_whenNextPageRequestFail_thenViewStateShouldBeIterativeLoadedWithError() {
        // GIVEN
        configureViewModelWithInitialLoad()
        testScheduler.createColdObservable([.next(0, true)])
            .bind(to: viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)
        let states = newViewStatesObserver(skipStates: 2)
        testScheduler.start()

        // WHEN
        let error = APIError.noDataError
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.failure(error))

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState), .next(0, .error(error.description))])
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
        mockPhotosAPI.getPhotosFuncCheck.arguments?.3(.success(.mocked(photos: [])))

        // THEN
        let expectedViewState = SearchViewController.State.loaded(.iterative)
        XCTAssertEqual(states.events, [.next(0, expectedViewState)])
    }
}
