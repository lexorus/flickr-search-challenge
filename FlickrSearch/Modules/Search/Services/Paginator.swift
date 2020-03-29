import Foundation

final class Paginator {
    let pageSize: UInt
    private(set) var currentPage: UInt = 1
    private(set) var totalNumberOfPages: UInt

    var nextPage: UInt? { isLastPage ? nil : currentPage + 1 }
    var isLastPage: Bool { currentPage == totalNumberOfPages }
    var totalNumberOfItems: UInt { currentPage * pageSize }

    init(pageSize: UInt, totalNumberOfPages: UInt) {
        self.totalNumberOfPages = totalNumberOfPages
        self.pageSize = pageSize
    }

    @discardableResult
    func advance() -> UInt? {
        if isLastPage { return nil }
        currentPage += 1

        return currentPage
    }
}

extension Paginator {
    convenience init(with photosPage: PhotosPage) {
        self.init(pageSize: photosPage.itemsPerPage,
                  totalNumberOfPages: photosPage.totalNumberOfPages)
    }
}

extension Paginator: Equatable {
    static func == (lhs: Paginator, rhs: Paginator) -> Bool {
        return lhs.pageSize == rhs.pageSize &&
            lhs.currentPage == rhs.currentPage &&
            lhs.totalNumberOfItems == rhs.totalNumberOfItems
    }
}
