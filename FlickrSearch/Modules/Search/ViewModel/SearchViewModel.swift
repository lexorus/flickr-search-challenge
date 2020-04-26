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

    private let viewStateReducer = SearchViewStateReducer()
    private var photos = BehaviorSubject(value: [Photo]())
    private var searchPage = SearchPage(query: .empty)

    private let fetcher: FetcherType
    private let disposeBag = DisposeBag()

    let viewState = BehaviorSubject(value: ViewState.empty)
    var items: Observable<[PhotoCell.Model]> { photos.map { $0.map(self.photoCellModel(for:)) } }

    let searchText = BehaviorSubject(value: String.empty)
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        self.fetcher = fetcher

        searchText.asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: compose(reduce, compose(ViewEvent.searchTextDidChange, reducer)))
            .disposed(by: disposeBag)

        isScrolledToBottom.asObserver()
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in ViewEvent.didScrolledToButtom }
            .subscribe(onNext: compose(reducer, reduce))
            .disposed(by: disposeBag)
    }

    private func reduce(using reducer: Reducer) {
        guard let viewState = try? viewState.value(), let photos = try? photos.value() else { return }
        reducer(viewState, photos)
            .subscribe(onNext: weakify(self, SearchViewModel.set))
            .disposed(by: disposeBag)
    }

    private func set(page: SearchPage, viewState: ViewState, newPhotos: [Photo]) {
        guard let photos = try? photos.value() else { return }
        searchPage = page
        let newPhotos = newPhotos
            .removingDuplicates(existingIds: photos.map(\.id))
        self.photos.onNext(photos + newPhotos)
        self.viewState.onNext(viewState)
    }

    private func reducer(for viewEvent: ViewEvent) -> Reducer {
        let searchPage: SearchPage = {
            switch viewEvent {
            case .searchTextDidChange(let text): return .init(query: text)
            case .didScrolledToButtom: return self.searchPage
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

private extension Array where Element == Photo {
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
