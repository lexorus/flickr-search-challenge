import Foundation
import PhotosAPI
import RxSwift
import RxRelay

final class SearchViewModel {
    private let viewStateReducer = SearchViewStateReducer()
    private var photos = BehaviorSubject(value: [Photo]())
    private var searchPage = SearchPage(query: .empty)

    private let fetcher: FetcherType
    private let disposeBag = DisposeBag()

    var viewState = BehaviorSubject(value: SearchViewController.State.empty)
    var items: Observable<[PhotoCell.Model]> { photos.map { $0.map(self.photoCellModel(for:)) } }
    let searchText = BehaviorSubject(value: String.empty)
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        self.fetcher = fetcher

        searchText.asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: searchTextDidChange(text:))
            .disposed(by: disposeBag)

        isScrolledToBottom.asObserver()
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .subscribe(onNext: loadNextPage)
            .disposed(by: disposeBag)
    }

    private func searchTextDidChange(text: String) {
        update(using: reducer(for: .searchTextDidChange(text)))
    }

    private func loadNextPage() {
        update(using: reducer(for: .didScrolledToButtom))
    }

    func update(using reducer: (_ viewState: SearchViewController.State, _ photos: [Photo]) -> BehaviorRelay<(page: SearchPage, viewState: SearchViewController.State, newPhotos: [Photo])>) {
        reducer(try! viewState.value(), try! photos.value())
            .subscribe(onNext: weakify(self, SearchViewModel.set))
            .disposed(by: disposeBag)
    }

    func set(page: SearchPage, viewState: SearchViewController.State, newPhotos: [Photo]) {
        searchPage = page
        let newPhotos = newPhotos
            .removingDuplicates(existingIds: try! photos.value().map(\.id))
        self.photos.onNext(try! photos.value() + newPhotos)
        self.viewState.onNext(viewState)
    }

    enum ViewEvent {
        case searchTextDidChange(String)
        case didScrolledToButtom
    }

    func reducer(for viewEvent: ViewEvent) ->
        (_ viewState: SearchViewController.State, _ photos: [Photo]) -> BehaviorRelay<(page: SearchPage, viewState: SearchViewController.State, newPhotos: [Photo])> {
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

// swiftlint:disable identifier_name
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> ((B, C) -> D) {
    return { a in
        return { b, c in
            return f(a, b, c)
        }
    }
}

func weakify<T: AnyObject, U, V, W>(_ instance: T,
                                    _ function: @escaping (T) -> (U, V, W) -> Void) -> ((U, V, W) -> Void) {
    return { [weak instance] u, v, w in
        return instance.flatMap(function)?(u, v, w)
    }
}
// swiftlint:enable identifier_name
