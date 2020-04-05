import Foundation

protocol FlickrFetcherType {
    @discardableResult
    func perform<T: Decodable>(_ request: FlickrRequest,
                               callback: @escaping (Result<T, APIError>) -> Void) -> Cancellable

    func getData(from stringURL: String,
                 callback: @escaping (Result<Data, APIError>) -> Void)
}

final class FlickrFetcher: FlickrFetcherType {
    private let requestBuilder: RequestBuilderType
    private let urlSession: URLSessionType
    private let decoder = JSONDecoder()

    init(apiKey: String,
         urlSession: URLSessionType = URLSession.shared,
         requestBuilder: (String) -> RequestBuilderType = RequestBuilder.init) {
        self.requestBuilder = requestBuilder(apiKey)
        self.urlSession = urlSession
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

enum APIError: Swift.Error, Equatable {
    case failedToBuildURLRequest
    case apiError(Swift.Error?)
    case flickAPIError(FlickrError)
    case noDataError
    case decodingError(Swift.Error?)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToBuildURLRequest, .failedToBuildURLRequest),
             (.apiError, .apiError),
             (.noDataError, .noDataError),
             (.decodingError, .decodingError):
            return true
        case (.flickAPIError(let lhsError), .flickAPIError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

extension APIError: CustomStringConvertible {
    private var genericError: String { "Something went wrong" }
    var description: String {
        switch self {
        case .failedToBuildURLRequest:
            return "Failed to build request."
        case .apiError(let error):
            return (error as NSError?)?.localizedDescription ?? genericError
        case .flickAPIError(let error):
            return error.message
        case .noDataError:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode data from server."
        }
    }
}
