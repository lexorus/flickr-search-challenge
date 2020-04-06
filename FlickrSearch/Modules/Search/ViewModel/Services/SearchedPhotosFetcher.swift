import Foundation
import PhotosAPI

protocol SearchedPhotosFetcherType: class {
    init(fetcher: FetcherType)
    var searchPhotosInfo: (searchString: String, paginator: Paginator)? { get }
    func cancelCurrentRequest()
    func loadFirstPage(for text: String,
                       callback: @escaping (SearchedPhotosFetcher.Result) -> Void)
    func loadNextPage(callback: @escaping (SearchedPhotosFetcher.Result) -> Void)
}

final class SearchedPhotosFetcher: SearchedPhotosFetcherType {
    private let pageSize: UInt = 21
    private let fetcher: FetcherType
    private(set) var searchPhotosInfo: (searchString: String, paginator: Paginator)?
    private(set) weak var currentRequest: Cancellable?

    init(fetcher: FetcherType) {
        self.fetcher = fetcher
    }

    func cancelCurrentRequest() {
        searchPhotosInfo = nil
        currentRequest?.cancel()
        currentRequest = nil
    }

    func loadFirstPage(for text: String, callback: @escaping (Result) -> Void) {
        cancelCurrentRequest()
        currentRequest = fetcher.getPhotos(for: text, pageNumber: 1, pageSize: pageSize) { [weak self] result in
            switch result {
            case .success(let photos):
                self?.searchPhotosInfo = (text, Paginator(with: photos))
                let result: Result = photos.photos.isEmpty ?
                    .empty :
                    .photos(photos.photos)
                callback(result)
            case .failure(let error):
                callback(.error(error))
            }
        }
    }

    func loadNextPage(callback: @escaping (Result) -> Void) {
        guard let getPhotosInfo = searchPhotosInfo,
            let nextPage = getPhotosInfo.paginator.nextPage else { return }
        let paginator = getPhotosInfo.paginator
        currentRequest = fetcher.getPhotos(for: getPhotosInfo.searchString,
                          pageNumber: nextPage, pageSize: paginator.pageSize) { result in
            switch result {
            case .success(let photos):
                if photos.photos.isEmpty {
                    callback(.empty)
                } else {
                    paginator.advance()
                    callback(.photos(photos.photos))
                }
            case .failure(let error):
                callback(.error(error))
            }
        }
    }

    enum Result: Equatable {
        case empty
        case photos([Photo])
        case error(APIError)
    }
}
