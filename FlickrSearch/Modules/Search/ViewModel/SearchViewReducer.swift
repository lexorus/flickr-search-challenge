import PhotosAPI
import RxSwift
import RxRelay

final class SearchViewReducer {
    typealias State = SearchViewModel.State

    private let loadPhotosAction: (_ query: String, _ pageNumber: UInt, _ pageSize: UInt) -> Single<PhotosPage>
    private var disposeBag = DisposeBag()

    init(loadPhotosAction: @escaping (_ query: String, _ pageNumber: UInt, _ pageSize: UInt) -> Single<PhotosPage>) {
        self.loadPhotosAction = loadPhotosAction
    }

    func reduce(event: SearchViewController.Event, state: State) -> BehaviorRelay<State> {
        disposeBag = DisposeBag()
        switch event {
        case .searchTextDidChange(let query): return initialLoadingRelay(query: query, currentState: state)
        case .didScrolledToBottom: return iterativeLoadingRelay(currentState: state)
        }
    }

    // MARK: - Initial loading

    private func initialLoadingRelay(query: String, currentState: State) -> BehaviorRelay<State> {
        if query.isEmpty { return .init(value: .empty) }
        let searchPage = SearchPage(query: query)
        let relay = BehaviorRelay<State>.initialLoadingRelay(searchPage: searchPage, photos: currentState.photos)
        performInitialLoading(into: relay, using: searchPage)

        return relay
    }

    private func performInitialLoading(into relay: BehaviorRelay<State>, using searchPage: SearchPage) {
        loadPhotosAction(searchPage.query,
                         searchPage.number,
                         searchPage.size)
            .asObservable()
            .subscribe(onNext: { (photosPage) in
                let updatesSearchPage = SearchPage(query: searchPage.query,
                                                   pageSize: photosPage.itemsPerPage,
                                                   totalNumberOfPages: photosPage.totalNumberOfPages,
                                                   currentPage: photosPage.pageNumber)
                if photosPage.photos.isEmpty { return relay.accept(.noResult(for: updatesSearchPage)) }
                relay.accept(.initialLoaded(page: updatesSearchPage, photos: photosPage.photos.removingDuplicates()))
            }, onError: { (error) in
                relay.accept(.error(page: .empty, error: error))
            }).disposed(by: disposeBag)
    }

    // MARK: - Iterative loading

    private func iterativeLoadingRelay(currentState: State) -> BehaviorRelay<State> {
        guard let nextPage = currentState.searchPage.next() else { return .init(value: currentState)}
        let relay = BehaviorRelay<State>.iterativeLoading(nextPage: nextPage, photos: currentState.photos)
        performIterativeLoading(into: relay, using: nextPage, currentState: currentState)

        return relay
    }

    private func performIterativeLoading(into relay: BehaviorRelay<State>,
                                         using nextPage: SearchPage,
                                         currentState: State) {
        loadPhotosAction(nextPage.query,
                         nextPage.number,
                         nextPage.size)
            .asObservable()
            .subscribe(onNext: { (photosPage) in
                let updatesSearchPage = SearchPage(query: nextPage.query,
                                                   pageSize: photosPage.itemsPerPage,
                                                   totalNumberOfPages: photosPage.totalNumberOfPages,
                                                   currentPage: photosPage.pageNumber)
                if photosPage.photos.isEmpty {
                    return relay.accept(.empty(searchPage: updatesSearchPage,
                                               photos: currentState.photos))
                }
                relay.accept(.iterativeLoaded(page: updatesSearchPage,
                                              photos: currentState.photos.addRemovingExisting(photosPage.photos)))
            }, onError: { (error) in
                relay.accept(.iterativeLoaded(page: nextPage, photos: currentState.photos))
                relay.accept(.error(page: nextPage, error: error, photos: currentState.photos))
            }).disposed(by: disposeBag)
    }
}

private extension SearchViewModel.State {
    static var empty: SearchViewModel.State {
        .init(searchPage: .empty, viewState: .empty, photos: [])
    }

    static func empty(searchPage: SearchPage, photos: [Photo]) -> SearchViewModel.State {
        .init(searchPage: searchPage,
              viewState: .loaded(.iterative),
              photos: photos)
    }

    static func noResult(for page: SearchPage) -> SearchViewModel.State {
        .init(searchPage: page, viewState: .noResult, photos: [])
    }

    static func initialLoaded(page: SearchPage, photos: [Photo]) -> SearchViewModel.State {
        .init(searchPage: page, viewState: .loaded(.initial), photos: photos)
    }

    static func iterativeLoaded(page: SearchPage, photos: [Photo]) -> SearchViewModel.State {
        .init(searchPage: page, viewState: .loaded(.iterative), photos: photos)
    }

    static func error(page: SearchPage, error: Error, photos: [Photo] = []) -> SearchViewModel.State {
        .init(searchPage: page,
              viewState: .error((error as? APIError)?.description ?? "Unknown Error"),
              photos: photos)
    }
}

private extension BehaviorRelay where Element == SearchViewModel.State {
    static func initialLoadingRelay(searchPage: SearchPage, photos: [Photo]) -> BehaviorRelay<Element> {
        .init(value: .init(searchPage: searchPage,
                           viewState: .loading(.initial),
                           photos: photos))
    }

    static func iterativeLoading(nextPage: SearchPage, photos: [Photo]) -> BehaviorRelay<Element> {
        .init(value: .init(searchPage: nextPage,
                           viewState: .loading(.iterative),
                           photos: photos))
    }
}

private extension Array where Element == Photo {
    func addRemovingExisting(_ photos: [Photo]) -> [Photo] {
        self + photos.removingDuplicates(existingIds: map(\.id))
    }

    // Noticed that Flickr can return multiple photos with the same id in one response.
    // Which will break the animated collection logic and may lead to crash.
    // It also does make sense to show identical photos for one query.
    // This surely affects performance, but since we are working with small datasets
    // it shouldn't be visible.
    func removingDuplicates(existingIds: [String] = []) -> [Photo] {
        let existingIdsSet = Set(existingIds)
        let newPhotosRemovingExisting = filter { !existingIdsSet.contains($0.id) }
        var idsSet = Set<String>()
        return newPhotosRemovingExisting.reduce([]) { acc, element in
            if idsSet.contains(element.id) { return acc }
            idsSet.insert(element.id)
            return acc + [element]
        }
    }
}
