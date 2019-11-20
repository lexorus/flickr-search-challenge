import Foundation
@testable import FlickrSearchChallenge

final class MockFetcher: FetcherType {

    var apiKey: String?
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    var getPhotosCancellableStub: MockCancellable = MockCancellable()
    var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<PhotosPage, APIError>) -> Void)>()
    @discardableResult
    func getPhotos(for query: String, pageNumber: UInt, pageSize: UInt, callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))

        return getPhotosCancellableStub
    }

    var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        getImageDataFuncCheck.call((photo, callback))
    }
}
