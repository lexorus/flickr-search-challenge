import Foundation
import RxSwift

protocol ImageStorage {
    func getImageData(_ id: String) -> Single<Data>
    func set(imageData: Data, for key: String) -> Single<Void>
}

enum ImageStorageError: Error, Equatable {
    case notFound
}

final class NSCacheImageStorage: ImageStorage {
    private let cache = Atomic<NSCache<NSString, NSData>>(.init())
    private let queue = DispatchQueue(label: "com.lexorus.FlickrSearch.ImageCacher", qos: .utility)

    func getImageData(_ id: String) -> Single<Data> {
        return Single.create { observer in
            self.queue.async { [weak self] in
                guard let self = self,
                    let imageData = self.cache.value.object(forKey: id as NSString) else {
                        observer(.error(ImageStorageError.notFound))
                        return
                }
                observer(.success(imageData as Data))
            }

            return Disposables.create()
        }
    }

    func set(imageData: Data, for key: String) -> Single<Void> {
        return Single.create { observer in
            self.queue.async { [weak self] in
                guard let self = self else { return }
                self.cache.value.setObject(imageData as NSData, forKey: key as NSString)
                observer(.success(()))
            }

            return Disposables.create()
        }
    }
}
