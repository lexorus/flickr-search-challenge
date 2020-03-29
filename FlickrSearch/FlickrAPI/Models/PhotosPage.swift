import Foundation

struct PhotosPage: Decodable, Equatable {
    let pageNumber: UInt
    let totalNumberOfPages: UInt
    let itemsPerPage: UInt
    let totalItems: String
    let photos: [Photo]

    private enum CodingKeys: String, CodingKey {
        case pageNumber = "page"
        case totalNumberOfPages = "pages"
        case itemsPerPage = "perpage"
        case totalItems = "total"
        case photos = "photo"
    }
}
