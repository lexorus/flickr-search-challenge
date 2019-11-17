import Foundation

final class FlickrFetcher {
    private let requestBuilder: RequestBuilderType
    private let urlSession: URLSessionType
    private let decoder = JSONDecoder()

    init(apiKey: String,
         urlSession: URLSessionType = URLSession.shared,
         requestBuilder: (String) -> RequestBuilderType = RequestBuilder.init) {
        self.requestBuilder = requestBuilder(apiKey)
        self.urlSession = urlSession
    }

    func perform<T: Decodable>(_ request: FlickrRequest, callback: @escaping (Result<T, Error>) -> Void) {
        guard let urlRequest = requestBuilder.urlRequest(from: request) else {
            callback(.failure(.failedToBuildURLRequest))
            return
        }
        urlSession.perform(urlRequest) { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                (200..<300) ~= response.statusCode else {
                    callback(.failure(.apiError(error)))
                    return
            }
            guard let data = data else {
                callback(.failure(.noDataError))
                return
            }
            do {
                let decodedModel = try self.decoder.decode(T.self, from: data)
                callback(.success(decodedModel))
            } catch {
                callback(.failure(.decodingError(error)))
            }
        }
    }

    enum Error: Swift.Error, Equatable {
        case failedToBuildURLRequest
        case apiError(Swift.Error?)
        case noDataError
        case decodingError(Swift.Error?)

        static func == (lhs: FlickrFetcher.Error, rhs: FlickrFetcher.Error) -> Bool {
            switch (lhs, rhs) {
            case (.failedToBuildURLRequest, .failedToBuildURLRequest),
                 (.apiError, .apiError),
                 (.noDataError, .noDataError),
                 (.decodingError, .decodingError):
                return true
            default:
                return false
            }
        }

    }
}
