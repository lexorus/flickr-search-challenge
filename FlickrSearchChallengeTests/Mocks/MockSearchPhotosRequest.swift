import Foundation
@testable import FlickrSearchChallenge

extension SearchPhotosRequest {
    static func mocked(query: String = "query",
                       page: UInt = 1,
                       pageSize: UInt = 1) -> SearchPhotosRequest {
        return .init(query: query, page: page, pageSize: pageSize)
    }
}
