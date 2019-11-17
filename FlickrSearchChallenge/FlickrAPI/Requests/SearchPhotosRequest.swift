import Foundation

struct SearchPhotosRequest: FlickrRequest {
    let method = "flickr.photos.search"
    let query: String
    let page: UInt
    let pageSize: UInt

    let httpMethod: HTTPMethod = .get
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "per_page", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "text", value: query)
        ]
    }
}
