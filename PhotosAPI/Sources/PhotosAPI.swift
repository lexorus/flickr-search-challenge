import Foundation

public protocol PhotosAPI: AutoMockable {
    func getPhotos(query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable

    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable
}
