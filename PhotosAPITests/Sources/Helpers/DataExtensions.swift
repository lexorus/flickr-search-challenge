import Foundation
import PhotosAPIMocks

extension Data {
    init?(testBundleFileName: String, ofType type: String = "json") {
        try? self.init(bundleId: "com.lexorus.PhotosAPITests",
                       fileName: testBundleFileName,
                       type: type)
    }
}
