import Foundation

final class RequestBuilder {
    private let apiKey: String
    private let baseURL = "https://api.flickr.com/services/rest/"

    private var sharedQueryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "safe_search", value: "1")
        ]
    }

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func urlRequest(from request: FlickrRequest) -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = sharedQueryItems + request.queryItems
        guard let url = urlComponents?.url else {
            return nil
        }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = request.httpMethod.rawValue

        return requestURL
    }
}
