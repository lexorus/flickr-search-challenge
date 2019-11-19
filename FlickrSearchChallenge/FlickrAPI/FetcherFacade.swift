import Foundation

protocol FetcherType {
    init(apiKey: String)
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void)
    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void)
}

final class Fetcher: FetcherType {
    private let flickrFetcher: FlickrFetcher

    init(apiKey: String) {
        flickrFetcher = FlickrFetcher(apiKey: apiKey)
    }

    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) {
        let searchRequest = SearchPhotosRequest(query: query, page: pageNumber, pageSize: pageSize)
        flickrFetcher.perform(searchRequest) { (flickrResult: Result<FlickrResponse<Photos>, APIError>) in
            let result = flickrResult.flatMap { (flickrResponse) -> Result<PhotosPage, APIError> in
                switch flickrResponse.result {
                case .success(let photots): return .success(photots.photos)
                case .failure(let error): return .failure(.flickAPIError(error))
                }
            }
            callback(result)
        }
    }

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        let urlString = PhotoStringURLBuilder().urlString(for: photo)
        flickrFetcher.getData(from: urlString, callback: callback)
    }
}
