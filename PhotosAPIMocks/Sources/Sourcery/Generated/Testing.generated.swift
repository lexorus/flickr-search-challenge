// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import PhotosAPI

public final class MockCancellable: Cancellable {
    public init() {}
    public let cancelFuncCheck = ZeroArgumentsFuncCheck()
    public func cancel() {
        cancelFuncCheck.call()
    }
}

public final class MockPhotosAPI: PhotosAPI {
    public init() {}
    public let getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<PhotosPage, APIError>) -> Void)>()
    public var getPhotosStub = MockCancellable()
    public func getPhotos(query: String,                   pageNumber: UInt,                   pageSize: UInt,                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))
        return getPhotosStub
    }

    public let getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    public var getImageDataStub = MockCancellable()
    public func getImageData(for photo: Photo,                      callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable {
        getImageDataFuncCheck.call((photo, callback))
        return getImageDataStub
    }
}

extension Photo {
    public static func mocked(id: String = .init(), title: String = .init(), secret: String = .init(), server: String = .init(), farm: Int = .init()) -> Photo {
        return .init(id: id, title: title, secret: secret, server: server, farm: farm)
    }
}

extension PhotosPage {
    public static func mocked(pageNumber: UInt = .init(), totalNumberOfPages: UInt = .init(), itemsPerPage: UInt = .init(), totalItems: String = .init(), photos: [Photo] = .init()) -> PhotosPage {
        return .init(pageNumber: pageNumber, totalNumberOfPages: totalNumberOfPages, itemsPerPage: itemsPerPage, totalItems: totalItems, photos: photos)
    }
}

