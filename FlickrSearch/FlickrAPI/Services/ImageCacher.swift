import Foundation
import UIKit

protocol ImageCacherType {
    func getImageData(_ id: String, callback: @escaping (Data?) -> Void)
    func set(imageData: Data, for key: String)
}

final class ImageCacher: ImageCacherType {
    private let cache = Atomic<NSCache<NSString, NSData>>(.init())
    private let queue = DispatchQueue(label: "com.lexorus.FlickrSearch.ImageCacher", qos: .utility)

    func getImageData(_ id: String, callback: @escaping (Data?) -> Void) {
        queue.async { [weak self] in
            guard let self = self,
                let imageData = self.cache.value.object(forKey: id as NSString) else {
                    callback(nil)
                    return
            }
            callback(imageData as Data)
        }
    }

    func set(imageData: Data, for key: String) {
        queue.async { [weak self] in
        guard let self = self else { return }
            self.cache.value.setObject(imageData as NSData, forKey: key as NSString)
        }
    }
}
