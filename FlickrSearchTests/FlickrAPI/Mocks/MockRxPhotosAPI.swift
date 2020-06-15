import Foundation
import RxSwift
import PhotosAPI
import PhotosAPIMocks
@testable import FlickrSearch

final class MockRxPhotosAPI: RxPhotosAPI {
    var getPhotosStub: Single<PhotosPage> = .just(.mocked())
    var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt)>()
    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt) -> Single<PhotosPage> {
        getPhotosFuncCheck.call((query, pageNumber, pageSize))

        return getPhotosStub
    }

    var getImageDataStub: Single<Data> = .just(Data())
    var getImageDataFuncCheck = FuncCheck<Photo>()
    func getImageData(for photo: Photo) -> Single<Data> {
        getImageDataFuncCheck.call(photo)

        return getImageDataStub
    }
}
