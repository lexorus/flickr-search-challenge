import PhotosAPI

public final class MockPhotosAPI: PhotosAPI {
    public init() {}

    public var getPhotosStub = MockCancellable()
    public var getPhotosFuncCheck = FuncCheck<(String, UInt, UInt, (Result<PhotosPage, APIError>) -> Void)>()
    public func getPhotos(query: String, pageNumber: UInt, pageSize: UInt,
                          callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        getPhotosFuncCheck.call((query, pageNumber, pageSize, callback))

        return getPhotosStub
    }

    public var getImageDataFuncCheck = FuncCheck<(Photo, (Result<Data, APIError>) -> Void)>()
    public func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        getImageDataFuncCheck.call((photo, callback))
    }
}
