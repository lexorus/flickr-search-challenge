import Foundation
import RxSwift
import PhotosAPI

protocol ImageDataProvider {
    func getImageData(for photo: Photo) -> Single<Data>
}

final class ImageDataRepository: ImageDataProvider {
    private let imageStorage: ImageStorage = NSCacheImageStorage()
    private let imageFetcher: RxPhotosAPI

    init(imageFetcher: RxPhotosAPI) {
        self.imageFetcher = imageFetcher
    }

    func getImageData(for photo: Photo) -> Single<Data> {
        return imageStorage.getImageData(photo.id)
            .catchError { [weak self] error in
                guard let self = self,
                    let storageError = error as? ImageStorageError,
                    storageError == .notFound else { return .error(error) }
                return self.imageFetcher.getImageData(for: photo)
        }
    }
}
