import Foundation
import RxSwift
import PhotosAPIMocks
@testable import FlickrSearch

final class MockImageStorage: ImageStorage {
    var getImageDataStub: Single<Data> = .just(Data())
    var getImageDataFuncCheck = FuncCheck<String>()
    func getImageData(_ id: String) -> Single<Data> {
        getImageDataFuncCheck.call(id)

        return getImageDataStub
    }

    var setImageDataStub: Single<Void> = .just(())
    var setImageDataFuncCheck = FuncCheck<(Data, String)>()
    func set(imageData: Data, for key: String) -> Single<Void> {
        setImageDataFuncCheck.call((imageData, key))

        return setImageDataStub
    }
}
