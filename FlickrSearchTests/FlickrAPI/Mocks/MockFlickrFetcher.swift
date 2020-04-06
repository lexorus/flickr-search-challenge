import Foundation
@testable import PhotosAPI

final class MockFlickrFetcher<M: Decodable> {
    var getPhotosStub = MockCancellable()
    var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<M, APIError>) -> Void)>()

    var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
}

extension MockFlickrFetcher: PhotosAPI where M == PhotosPage {
    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt, callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))

        return getPhotosStub
    }

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        getImageDataFuncCheck.call((photo, callback))
    }
}
