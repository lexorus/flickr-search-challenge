import PhotosAPI
import RxSwift

protocol RxPhotosAPI {
    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt) -> Single<PhotosPage>
    func getImageData(for photo: Photo) -> Single<Data>
}

final class PhotosAPIRxAdapter: RxPhotosAPI {
    private let api: PhotosAPI

    init(photosAPI: PhotosAPI) {
        api = photosAPI
    }

    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt) -> Single<PhotosPage> {
        return Single.create { observer in
            let callback: (Result<PhotosPage, APIError>) -> Void = { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            let cancellable = self.api.getPhotos(query: query,
                                                 pageNumber: pageNumber,
                                                 pageSize: pageSize,
                                                 callback: callback)

            return Disposables.create { cancellable.cancel() }
        }
    }

    func getImageData(for photo: Photo) -> Single<Data> {
        return Single.create { observer in
            let callback: (Result<Data, APIError>) -> Void = { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            let cancellable = self.api.getImageData(for: photo, callback: callback)

            return Disposables.create { cancellable.cancel() }
        }
    }
}
