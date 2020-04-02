import Foundation
import RxSwift

final class SearchViewModel {
    private let fetcher: FetcherType
    private let searchPhotosFetcher: SearchedPhotosFetcherType
    private let disposeBag = DisposeBag()

    let viewState = BehaviorSubject(value: SearchViewController.State.empty)
    let items = BehaviorSubject(value: [PhotoCell.Model]())
    let searchText = BehaviorSubject(value: String.empty)
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        self.fetcher = fetcher
        self.searchPhotosFetcher = searchPhotosFetcher ?? SearchedPhotosFetcher(fetcher: fetcher)

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
        if text.isEmpty {
            searchPhotosFetcher.cancelCurrentRequest()
            viewState.onNext(.empty)
            return
        }
        viewState.onNext(.loading(.initial))
        searchPhotosFetcher.loadFirstPage(for: text) { [weak self] (result) in
            self?.process(initialLoadResult: result)
        }
    }

    private func process(initialLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            items.onNext([])
            viewState.onNext(.noResult)
        case .photos(let photos):
            items.onNext(photos.removingDuplicates().map(photoCellModel))
            viewState.onNext(.loaded(.initial))
        case .error(let error):
            viewState.onNext(.error(error.description))
        }
    }

    private func photoCellModel(for photo: Photo) -> PhotoCell.Model {
        let imageProvider: SearchCellModelsBuilder.ImageDataProvider = { [weak self] photo, callback in
            guard let welf = self else { return }
            welf.fetcher.getImageData(for: photo, callback: callback)
        }

        return SearchCellModelsBuilder().photoCellModel(for: photo,
                                                        imageProvider: imageProvider)
    }

    private func loadNextPage() {
        guard let paginator = searchPhotosFetcher.searchPhotosInfo?.paginator, !paginator.isLastPage else { return }
        viewState.onNext(.loading(.iterative))
        searchPhotosFetcher.loadNextPage { [weak self] result in
            self?.process(nextPageLoadResult: result)
        }
    }

    private func process(nextPageLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            viewState.onNext(.loaded(.iterative))
        case .photos(let photos):
            let currentModels = (try? items.value()) ?? []
            let newModels = photos
                .removingDuplicates(existingIds: currentModels.map(\.id))
                .map(photoCellModel)
            items.onNext(currentModels + newModels)
            viewState.onNext(.loaded(.iterative))
        case .error(let error):
            debugPrint("Failed to load next page. Error: \(error.description)")
            viewState.onNext(.loaded(.iterative))
        }
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
