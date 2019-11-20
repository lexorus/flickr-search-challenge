import Foundation

protocol FetcherType {
    init(apiKey: String)

    @discardableResult
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable

    @discardableResult
    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable
}

final class Fetcher: FetcherType {
    private let flickrFetcher: FlickrFetcher

    init(apiKey: String) {
        flickrFetcher = FlickrFetcher(apiKey: apiKey)
    }

    @discardableResult
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        let searchRequest = SearchPhotosRequest(query: query, page: pageNumber, pageSize: pageSize)
        return flickrFetcher.perform(searchRequest) { (flickrResult: Result<FlickrResponse<Photos>, APIError>) in
            let result = flickrResult.flatMap { (flickrResponse) -> Result<PhotosPage, APIError> in
                switch flickrResponse.result {
                case .success(let photots): return .success(photots.photos)
                case .failure(let error): return .failure(.flickAPIError(error))
                }
            }
            callback(result)
        }
    }

    @discardableResult
    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable {
        let urlString = PhotoStringURLBuilder().urlString(for: photo)
        return flickrFetcher.getData(from: urlString, callback: callback)
    }
}
