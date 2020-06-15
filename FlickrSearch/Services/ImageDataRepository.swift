import Foundation
import RxSwift
import PhotosAPI

protocol ImageDataProvider {
    func getImageData(for photo: Photo) -> Single<Data>
}

final class ImageDataRepository: ImageDataProvider {
    private let imageStorage: ImageStorage
    private let imageFetcher: RxPhotosAPI

    init(imageFetcher: RxPhotosAPI, imageStorage: ImageStorage = NSCacheImageStorage()) {
        self.imageFetcher = imageFetcher
        self.imageStorage = imageStorage
    }

    func getImageData(for photo: Photo) -> Single<Data> {
        return imageStorage.getImageData(photo.id)
            .catchError { [weak self] error in
                guard let self = self,
                    let storageError = error as? ImageStorageError,
                    storageError == .notFound else { return .error(error) }
                return self.imageFetcher.getImageData(for: photo)
                    .do(onSuccess: { [weak self] result in
                        _ = self?.imageStorage.set(imageData: result, for: photo.id).subscribe()
                    })
        }
    }
}
