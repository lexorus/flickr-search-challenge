import Foundation
@testable import FlickrSearch

extension Paginator {
    static func mocked(pageSize: UInt = 2, totalNumberOfPages: UInt = 2) -> Paginator {
        return .init(pageSize: pageSize, totalNumberOfPages: totalNumberOfPages)
    }
}
