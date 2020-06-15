import Foundation
import RxSwift
import PhotosAPI
import PhotosAPIMocks
@testable import FlickrSearch

final class MockImageDataProvider: ImageDataProvider {
    var getImageDataStub: Single<Data> = Single<Data>.just(Data())
    var getImageDataFuncCheck = FuncCheck<Photo>()
    func getImageData(for photo: Photo) -> Single<Data> {
        getImageDataFuncCheck.call(photo)

        return getImageDataStub
    }
}
