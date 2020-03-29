import Foundation
@testable import FlickrSearch

final class MockImageCacher: ImageCacherType {
    var getImageDataFuncCheck = FuncCheck<(String, (Data?) -> Void)>()
    func getImageData(_ id: String, callback: @escaping (Data?) -> Void) {
        getImageDataFuncCheck.call((id, callback))
    }

    var setImageDataFuncCheck = FuncCheck<(Data, String)>()
    func set(imageData: Data, for key: String) {
        setImageDataFuncCheck.call((imageData, key))
    }
}
