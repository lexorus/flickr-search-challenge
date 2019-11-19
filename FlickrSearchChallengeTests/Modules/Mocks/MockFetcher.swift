import Foundation
@testable import FlickrSearchChallenge

final class MockFetcher: FetcherType {
    var apiKey: String?
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<PhotosPage, APIError>) -> Void)>()
    func getPhotos(for query: String, pageNumber: UInt, pageSize: UInt, callback: @escaping (Result<PhotosPage, APIError>) -> Void) {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))
    }

    var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        getImageDataFuncCheck.call((photo, callback))
    }
}
