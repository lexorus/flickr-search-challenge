import Foundation

public struct PhotosPage: Decodable, Equatable {
    public let pageNumber: UInt
    public let totalNumberOfPages: UInt
    public let itemsPerPage: UInt
    public let totalItems: String
    public let photos: [Photo]

    public init(pageNumber: UInt, totalNumberOfPages: UInt, itemsPerPage: UInt, totalItems: String, photos: [Photo]) {
        self.pageNumber = pageNumber
        self.totalNumberOfPages = totalNumberOfPages
        self.itemsPerPage = itemsPerPage
        self.totalItems = totalItems
        self.photos = photos
    }

    private enum CodingKeys: String, CodingKey {
        case pageNumber = "page"
        case totalNumberOfPages = "pages"
        case itemsPerPage = "perpage"
        case totalItems = "total"
        case photos = "photo"
    }
}
