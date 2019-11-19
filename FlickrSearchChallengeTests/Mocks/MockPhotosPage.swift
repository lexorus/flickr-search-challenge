import Foundation
@testable import FlickrSearchChallenge

extension PhotosPage {
    static func mocked(pageNumber: UInt = 1,
                       totalNumberOfPages: UInt = 2,
                       itemsPerPage: UInt = 2,
                       totalItems: String = "4",
                       photos: [Photo] = []) -> PhotosPage {
        return .init(pageNumber: pageNumber,
                     totalNumberOfPages: totalNumberOfPages,
                     itemsPerPage: itemsPerPage,
                     totalItems: totalItems,
                     photos: photos)
    }
}
