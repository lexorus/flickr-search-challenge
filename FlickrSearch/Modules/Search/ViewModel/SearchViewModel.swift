import Foundation
import PhotosAPI
import RxSwift
import RxRelay

final class SearchViewModel {
    typealias ViewEvent = SearchViewController.Event
    typealias ViewState = SearchViewController.State
    private typealias Reducer =
        (_ viewState: ViewState, _ photos: [Photo]) ->
        BehaviorRelay<(page: SearchPage, viewState: ViewState, newPhotos: [Photo])>

    private let viewStateReducer = SearchViewReducer()
    private var photos = BehaviorSubject(value: [Photo]())
    private var searchPage = SearchPage(query: .empty)

    private let fetcher: FetcherType
    private let disposeBag = DisposeBag()

    let viewState = BehaviorSubject(value: ViewState.empty)
    var items: Observable<[PhotoCell.Model]> { photos.map { $0.map(self.photoCellModel(for:)) } }

    let searchText = BehaviorSubject(value: String.empty)
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736")) {
        self.fetcher = fetcher

        searchText.asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: compose(reduce, compose(ViewEvent.searchTextDidChange, reducer)))
            .disposed(by: disposeBag)

        isScrolledToBottom.asObserver()
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in ViewEvent.didScrolledToBottom }
            .subscribe(onNext: compose(reducer, reduce))
            .disposed(by: disposeBag)
    }

    private func reduce(using reducer: Reducer) {
        guard let viewState = try? viewState.value(), let photos = try? photos.value() else { return }
        reducer(viewState, photos)
            .subscribe(onNext: weakify(self, SearchViewModel.set))
            .disposed(by: disposeBag)
    }

    private func set(page: SearchPage, viewState: ViewState, photos: [Photo]) {
        searchPage = page
        self.photos.onNext(photos)
        self.viewState.onNext(viewState)
    }

    private func reducer(for viewEvent: ViewEvent) -> Reducer {
        let searchPage: SearchPage = {
            switch viewEvent {
            case .searchTextDidChange(let text): return .init(query: text)
            case .didScrolledToBottom: return self.searchPage
            }
        }()
        return curry(viewStateReducer.reduce)(searchPage)
    }

    private func photoCellModel(for photo: Photo) -> PhotoCell.Model {
        let imageProvider: SearchCellModelsBuilder.ImageDataProvider = { [weak self] photo, callback in
            guard let welf = self else { return }
            welf.fetcher.getImageData(for: photo, callback: callback)
        }

        return SearchCellModelsBuilder().photoCellModel(for: photo,
                                                        imageProvider: imageProvider)
    }
}
