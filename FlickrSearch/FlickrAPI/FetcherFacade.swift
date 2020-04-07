import Foundation
import PhotosAPI

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
    private let flickrFetcher: PhotosAPI
    private let imageCacher: ImageCacherType

    init(apiKey: String,
         flickrFetcher: PhotosAPI? = nil,
         imageCacher: ImageCacherType = ImageCacher()) {
        self.flickrFetcher = flickrFetcher ?? FlickrPhotosAPI(key: apiKey)
        self.imageCacher = imageCacher
    }

    @discardableResult
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        return flickrFetcher.getPhotos(query: query, pageNumber: pageNumber, pageSize: pageSize, callback: callback)
    }

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        imageCacher.getImageData(photo.id) { [weak self] (data) in
            if let data = data {
                callback(.success(data))
                return
            }
            self?.flickrFetcher.getImageData(for: photo) { [weak self] result in
                callback(result)
                guard let data = try? result.get() else { return }
                self?.imageCacher.set(imageData: data, for: photo.id)
            }
        }
    }
}
