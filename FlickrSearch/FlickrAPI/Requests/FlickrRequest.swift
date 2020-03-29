import Foundation

protocol FlickrRequest {
    var httpMethod: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}
