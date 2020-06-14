import Foundation
import PhotosAPI
import RxSwift
import RxRelay

final class SearchViewModel {
    struct State {
        let searchPage: SearchPage
        let viewState: SearchViewController.State
        let photos: [Photo]
    }

    typealias ViewEvent = SearchViewController.Event
    typealias ViewState = SearchViewController.State
    private typealias Reducer = (State) -> BehaviorRelay<State>

    private let viewStateReducer: SearchViewReducer
    private let cellModelsBuilder: SearchCellModelsBuilder
    private var photos = BehaviorSubject(value: [Photo]())
    private var searchPage = SearchPage(query: .empty)

    private let disposeBag = DisposeBag()

    let viewState = BehaviorSubject(value: ViewState.empty)
    var items: Observable<[PhotoCell.Model]> { photos.map { $0.map(self.photoCellModel(for:)) } }

    let searchText = BehaviorSubject(value: String.empty)
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(photosAPI: PhotosAPI = FlickrPhotosAPI(key: "3e7cc266ae2b0e0d78e279ce8e361736")) {
        let rxPhotosAPI = PhotosAPIRxAdapter(photosAPI: photosAPI)
        self.viewStateReducer = SearchViewReducer(loadPhotosAction: rxPhotosAPI.getPhotos)
        let imageDataRepository = ImageDataRepository(imageFetcher: rxPhotosAPI)
        self.cellModelsBuilder = SearchCellModelsBuilder(imageDataProvider: imageDataRepository)

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
        reducer(.init(searchPage: searchPage, viewState: viewState, photos: photos))
            .subscribe(onNext: weakify(self, SearchViewModel.set))
            .disposed(by: disposeBag)
    }

    private func set(state: State) {
        searchPage = state.searchPage
        self.photos.onNext(state.photos)
        self.viewState.onNext(state.viewState)
    }

    private func reducer(for viewEvent: ViewEvent) -> Reducer {
        return curry(viewStateReducer.reduce)(viewEvent)
    }

    private func photoCellModel(for photo: Photo) -> PhotoCell.Model {
        return cellModelsBuilder.photoCellModel(for: photo)
    }
}
