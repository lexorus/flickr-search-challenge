import Foundation
import PhotosAPI

protocol FetcherType {
    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void)
}

final class Fetcher: FetcherType {
    private let flickrFetcher: PhotosAPI
    private let imageCacher: ImageCacherType

    init(flickrFetcher: PhotosAPI,
         imageCacher: ImageCacherType = ImageCacher()) {
        self.flickrFetcher = flickrFetcher
        self.imageCacher = imageCacher
    }

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        imageCacher.getImageData(photo.id) { [weak self] (data) in
            if let data = data {
                callback(.success(data))
                return
            }
            _ = self?.flickrFetcher.getImageData(for: photo) { [weak self] result in
                callback(result)
                guard let data = try? result.get() else { return }
                self?.imageCacher.set(imageData: data, for: photo.id)
            }
        }
    }
}
