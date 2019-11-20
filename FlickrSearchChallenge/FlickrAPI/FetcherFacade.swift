import Foundation

protocol FetcherType {
    @discardableResult
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable

    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void)
}

final class Fetcher: FetcherType {
    private let flickrFetcher: FlickrFetcherType
    private let imageCacher: ImageCacherType

    init(apiKey: String,
         flickrFetcher: FlickrFetcherType? = nil,
         imageCacher: ImageCacherType = ImageCacher()) {
        self.flickrFetcher = flickrFetcher ?? FlickrFetcher(apiKey: apiKey)
        self.imageCacher = imageCacher
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

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        imageCacher.getImageData(photo.id) { [weak self] (data) in
            if let data = data {
                callback(.success(data))
                return
            }
            let urlString = PhotoStringURLBuilder().urlString(for: photo)
            self?.flickrFetcher.getData(from: urlString) { [weak self] result in
                callback(result)
                guard let data = try? result.get() else { return }
                self?.imageCacher.set(imageData: data, for: photo.id)
            }
        }
    }
}
