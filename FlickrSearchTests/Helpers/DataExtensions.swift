import Foundation

extension Data {
    init?(testBundleFileName: String, ofType type: String = "json") {
        try? self.init(bundleId: "com.lexorus.FlickrSearchTests",
                       fileName: testBundleFileName,
                       type: type)
    }
}
