import PhotosAPI

public final class MockPhotosAPI: PhotosAPI {
    public init() {}

    public var getPhotosStub = MockCancellable()
    public var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<PhotosPage, APIError>) -> Void)>()
    @discardableResult
    public func getPhotos(query: String, pageNumber: UInt, pageSize: UInt,
                          callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))

        return getPhotosStub
    }

    public var getImageDataStub = MockCancellable()
    public var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    @discardableResult
    public func getImageData(for photo: Photo,
                             callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable {
        getImageDataFuncCheck.call((photo, callback))

        return getImageDataStub
    }
}
