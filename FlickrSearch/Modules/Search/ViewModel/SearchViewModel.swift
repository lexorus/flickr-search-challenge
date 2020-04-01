import Foundation
import RxSwift

final class SearchViewModel {
    private let fetcher: FetcherType
    private let searchPhotosFetcher: SearchedPhotosFetcherType
    private let disposeBag = DisposeBag()

    let viewState = BehaviorSubject(value: SearchViewController.State.empty)
    let items = BehaviorSubject(value: [PhotoCell.Model]())
    let searchText = BehaviorSubject(value: "")
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        // Internals init
        self.fetcher = fetcher
        self.searchPhotosFetcher = searchPhotosFetcher ?? SearchedPhotosFetcher(fetcher: fetcher)

        // Subscriptions
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
        viewState.onNext(.loaded(.initial))
        searchPhotosFetcher.loadFirstPage(for: text) { [weak self] (result) in
            self?.process(initialLoadResult: result)
        }
    }

    private func process(initialLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            viewState.onNext(.noResult)
        case .photos(let photos):
            items.onNext(photos.map(photoCellModel))
            viewState.onNext(.loaded(.initial))
        case .error(let error):
            viewState.onNext(.error(error.localizedDescription))
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
        viewState.onNext(.loaded(.iterative([])))
        searchPhotosFetcher.loadNextPage { [weak self] result in
            self?.process(nextPageLoadResult: result)
        }
    }

    private func process(nextPageLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            viewState.onNext(.loaded(.iterative([])))
        case .photos(let photos):
            let currentModels = (try? items.value()) ?? []
            let newModels = photos.map(photoCellModel)
            items.onNext(currentModels + newModels)
            viewState.onNext(.loaded(.iterative([])))
        case .error(let error):
            debugPrint("Failed to load next page with error: \(error)")
            viewState.onNext(.loaded(.iterative([])))
        }
    }
}
