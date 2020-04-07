import Foundation
import MicroNetwork

public final class FlickrPhotosAPI: PhotosAPI {
    private let requestBuilder: RequestBuilderType
    private let network: Network
    private let decoder = JSONDecoder()

    public convenience init(key: String) {
        self.init(apiKey: key)
    }

    init(apiKey: String,
         network: Network = URLSession.shared,
         requestBuilder: (String) -> RequestBuilderType = RequestBuilder.init) {
        self.requestBuilder = requestBuilder(apiKey)
        self.network = network
    }

    public func getPhotos(query: String,
                          pageNumber: UInt,
                          pageSize: UInt,
                          callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        let searchRequest = SearchPhotosRequest(query: query, page: pageNumber, pageSize: pageSize)
        return perform(searchRequest) { (flickrResult: Result<FlickrResponse<Photos>, APIError>) in
            let result = flickrResult.flatMap { (flickrResponse) -> Result<PhotosPage, APIError> in
                switch flickrResponse.result {
                case .success(let photos): return .success(photos.photos)
                case .failure(let error): return .failure(.describedError(error.message))
                }
            }
            callback(result)
        }
    }

    public func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        let urlString = PhotoStringURLBuilder().urlString(for: photo)
        return getData(from: urlString, callback: callback)
    }

    @discardableResult
    private func perform<T: Decodable>(_ request: FlickrRequest,
                               callback: @escaping (Result<T, APIError>) -> Void) -> Cancellable {
        guard let urlRequest = requestBuilder.urlRequest(from: request) else {
            callback(.failure(.failedToBuildURLRequest))
            return EmptyCancellable()
        }
        return perform(urlRequest) { (dataResult) in
            let result = dataResult.flatMap { (data) -> Result<T, APIError> in
                do {
                    let decodedModel = try self.decoder.decode(T.self, from: data)
                    return .success(decodedModel)
                } catch {
                    return .failure(.decodingError(error))
                }
            }
            callback(result)
        }
    }

    private func getData(from stringURL: String, callback: @escaping (Result<Data, APIError>) -> Void) {
        guard let url = URL(string: stringURL) else {
            callback(.failure(.failedToBuildURLRequest))
            return
        }
        perform(URLRequest(url: url), callback: callback)
    }

    @discardableResult
    private func perform(_ request: URLRequest, callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable {
        return network.dataTask(with: request) { result in
            callback(result.mapError { $0.toAPIError() })
        }.toCancellable()
    }
}

extension NetworkError {
    func toAPIError() -> APIError {
        switch self {
        case .apiError(_, let error):
            return .apiError(error)
        case .noDataError:
            return .noDataError
        }
    }
}
