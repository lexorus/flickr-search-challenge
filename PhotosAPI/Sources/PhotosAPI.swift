import Foundation

protocol PhotosAPI {
    func getPhotos(for query: String,
                   pageNumber: UInt,
                   pageSize: UInt,
                   callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable

    func getImageData(for photo: Photo,
                      callback: @escaping (Result<Data, APIError>) -> Void)
}

final class FlickrFetcher: PhotosAPI {
    private let requestBuilder: RequestBuilderType
    private let urlSession: URLSessionType
    private let decoder = JSONDecoder()

    init(apiKey: String,
         urlSession: URLSessionType = URLSession.shared,
         requestBuilder: (String) -> RequestBuilderType = RequestBuilder.init) {
        self.requestBuilder = requestBuilder(apiKey)
        self.urlSession = urlSession
    }

    func getPhotos(for query: String, pageNumber: UInt, pageSize: UInt, callback: @escaping (Result<PhotosPage, APIError>) -> Void) -> Cancellable {
        let searchRequest = SearchPhotosRequest(query: query, page: pageNumber, pageSize: pageSize)
        return perform(searchRequest, callback: callback)
    }

    func getImageData(for photo: Photo, callback: @escaping (Result<Data, APIError>) -> Void) {
        let urlString = PhotoStringURLBuilder().urlString(for: photo)
        return getData(from: urlString, callback: callback)
    }

    @discardableResult
    func perform<T: Decodable>(_ request: FlickrRequest,
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

    func getData(from stringURL: String, callback: @escaping (Result<Data, APIError>) -> Void) {
        guard let url = URL(string: stringURL) else {
            callback(.failure(.failedToBuildURLRequest))
            return
        }
        perform(URLRequest(url: url), callback: callback)
    }

    @discardableResult
    private func perform(_ request: URLRequest, callback: @escaping (Result<Data, APIError>) -> Void) -> Cancellable {
        return urlSession.perform(request) { (data, response, error) in
            if (error as NSError?)?.code == NSURLErrorCancelled { return }
            guard let response = response as? HTTPURLResponse,
                (200..<300) ~= response.statusCode else {
                    callback(.failure(.apiError(error)))
                    return
            }
            guard let data = data else {
                callback(.failure(.noDataError))
                return
            }
            callback(.success(data))
        }
    }
}
