import Foundation

extension Data {
    public init(bundleId: String, fileName: String, type: String) throws {
        guard let bundle = Bundle(identifier: bundleId),
            let filePath = bundle.path(forResource: fileName, ofType: type) else {
                fatalError("Failed to get path for file: \(fileName) in bundle with id: \(bundleId)")
        }
        let fileURL = URL(fileURLWithPath: filePath)
        try self.init(contentsOf: fileURL)
    }
}
