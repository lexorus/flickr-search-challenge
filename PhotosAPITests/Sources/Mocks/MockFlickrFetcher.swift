import Foundation
@testable import PhotosAPI

final class MockFlickrFetcher<M: Decodable>: PhotosAPI {
    var getPhotosStub = MockCancellable()
    var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<M, APIError>) -> Void)>()
    func getPhotos(for query: String, pageNumber: UInt, pageSize: UInt, callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        // swiftlint:disable:next force_cast
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback  as! (Result<M, APIError>) -> Void))

        return getPhotosStub
    }

    var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        getImageDataFuncCheck.call((photo, callback))
    }
}
