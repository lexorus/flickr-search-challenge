import Foundation
import UIKit

final class SearchPresenter {
    private let fetcher: FetcherType
    private let searchPhotosFetcher: SearchedPhotosFetcherType
    private weak var view: SearchPresenterOutput?
    
    var cellModels = [PhotoCell.Model]()

    init(view: SearchPresenterOutput?,
         fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        self.view = view
        self.fetcher = fetcher
        self.searchPhotosFetcher = searchPhotosFetcher ?? SearchedPhotosFetcher(fetcher: fetcher)
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

// MARK: - SearchPresenterInput

extension SearchPresenter: SearchPresenterInput {
    func viewDidLoad() {
        view?.configure(for: .empty)
    }

    // MARK: - Initial load

    func searchTextDidChange(text: String) {
        guard text != searchPhotosFetcher.searchPhotosInfo?.searchString else { return }
        guard !text.isEmpty else {
            view?.configure(for: .empty)
            return
        }
        view?.configure(for: .loading(.initial))
        searchPhotosFetcher.loadFirstPage(for: text) { [weak self] (result) in
            self?.process(initialLoadResult: result)
        }
    }

    private func process(initialLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            view?.configure(for: .noResult)
        case .photos(let photos):
            cellModels = photos.map(photoCellModel)
            view?.configure(for: .loaded(.initial))
        case .error(let error):
            view?.configure(for: .error(error.localizedDescription))
        }
    }

    // MARK: - Iterative load

    func userDidScrollToBottom() {
        guard let paginator = searchPhotosFetcher.searchPhotosInfo?.paginator, !paginator.isLastPage else { return }
        view?.configure(for: .loading(.iterative([])))
        searchPhotosFetcher.loadNextPage { [weak self] result in
            self?.process(nextPageLoadResult: result)
        }
    }

    private func process(nextPageLoadResult result: SearchedPhotosFetcher.Result) {
        switch result {
        case .empty:
            view?.configure(for: .loaded(.iterative([])))
        case .photos(let photos):
            let indexPaths = indexPathsToInsert(for: photos.count)
            cellModels += photos.map(photoCellModel)
            view?.configure(for: .loaded(.iterative(indexPaths)))
        case .error(let error):
            debugPrint("Failed to load next page with error: \(error)")
            view?.configure(for: .loaded(.iterative([])))
        }
    }

    private func indexPathsToInsert(for newPhotosCount: Int) -> [IndexPath] {
        return (cellModels.count..<cellModels.count+newPhotosCount).map { IndexPath(row: $0, section: 0) }
    }
}
