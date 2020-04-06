import Foundation

extension Data {
    init?(testBundleFileName: String, ofType type: String = "json") {
        guard let bundle = Bundle(identifier: "com.lexorus.PhotosAPITests"),
            let filePath = bundle.path(forResource: testBundleFileName, ofType: type) else {
                return nil
        }
        let fileURL = URL(fileURLWithPath: filePath)
        try? self.init(contentsOf: fileURL)
    }
}
