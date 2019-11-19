import XCTest
@testable import FlickrSearchChallenge

final class PaginatorTests: XCTestCase {

    // MARK: - Initialization

    func test_whenInitialized_thenPageSizeIsSet() {
        // GIVEN
        let pageSize: UInt = 10

        // WHEN
        let paginator = Paginator(pageSize: pageSize, totalNumberOfPages: 10)

        // THEN
        XCTAssertEqual(paginator.pageSize, pageSize)
    }

    func test_whenInitialized_thenCurrentPageShouldBeFirstPage() {
        // GIVEN
        let pageSize: UInt = 10

        // WHEN
        let paginator = Paginator(pageSize: pageSize, totalNumberOfPages: 10)

        // THEN
        XCTAssertEqual(paginator.currentPage, 1)
    }

    func test_whenInitializedUsingPhotosPage_shouldTakeItsPageSizeAndNumberOfPages() {
        // GIVEN
        let itemsPerPage: UInt = 10
        let totalNumberOfPages: UInt = 2
        let photosPage = PhotosPage(pageNumber: 1,
                                    totalNumberOfPages: totalNumberOfPages,
                                    itemsPerPage: itemsPerPage,
                                    totalItems: "100",
                                    photos: [])

        // WHEN
        let paginator = Paginator(with: photosPage)

        // THEN
        XCTAssertEqual(paginator.pageSize, itemsPerPage)
        XCTAssertEqual(paginator.totalNumberOfPages, totalNumberOfPages)
    }

    // MARK: - nextPage

    func test_whenNextPageIsCalled_thenIncrementedCurrentPageShouldBeReturned() {
        // GIVEN
        let pageSize: UInt = 10

        // WHEN
        let paginator = Paginator(pageSize: pageSize, totalNumberOfPages: 10)


        // THEN
        XCTAssertEqual(paginator.nextPage, 2)
    }

    func test_whenNextPageIsCalled_whenCurrentPageIsLast_thenNilShouldBeReturned() {
        // GIVEN
        let pageSize: UInt = 10

        // WHEN
        let paginator = Paginator(pageSize: pageSize, totalNumberOfPages: 1)


        // THEN
        XCTAssertEqual(paginator.nextPage, nil)
    }

    // MARK: - isLastPage

    func test_whenCheckingForLastPage_thenItShouldReturnTrueIfTheCurrentPageIsLastPage() {
        // GIVEN
        let paginator = Paginator(pageSize: 10, totalNumberOfPages: 1)

        // WHEN
        let isLastPage = paginator.isLastPage

        //THEN
        XCTAssertTrue(isLastPage)
    }

    func test_whenCheckingForLastPage_thenItShouldReturnFalseIfTheCurrentPageIsLastPage() {
        // GIVEN
        let paginator = Paginator(pageSize: 10, totalNumberOfPages: 2)

        // WHEN
        let isLastPage = paginator.isLastPage

        //THEN
        XCTAssertFalse(isLastPage)
    }

    // MARK: - totalNumberOfItems

    func test_whenTotalNumberOfItemsIsRequested_thenTheRightNumberShouldBeReturned() {
        // GIVEN
        let numberOfItemsPerPage: UInt = 10
        let paginator = Paginator(pageSize: numberOfItemsPerPage, totalNumberOfPages: 1)

        // WHEN
        let totalNumberOfItems = paginator.totalNumberOfItems

        //THEN
        XCTAssertEqual(numberOfItemsPerPage, totalNumberOfItems)
    }

    // MARK: - advance

    func test_whenIsLastPage_whenAdvanceIsCalled_thenNilShouldBeReturned() {
        // GIVEN
        let paginator = Paginator(pageSize: 10, totalNumberOfPages: 1)

        // WHEN
        let result = paginator.advance()

        // THEN
        XCTAssertNil(result)
    }

    func test_whenAdvanceIsCalled_thenNextPageShouldBeReturned() {
        // GIVEN
        let paginator = Paginator(pageSize: 10, totalNumberOfPages: 2)

        // WHEN
        let result = paginator.advance()

        // THEN
        XCTAssertEqual(result, 2)
    }

    func test_whenAdvanceIsCalled_thenCurrentPageShouldBeIncremented() {
        // GIVEN
        let paginator = Paginator(pageSize: 10, totalNumberOfPages: 2)

        // WHEN
        paginator.advance()

        // THEN
        XCTAssertEqual(paginator.currentPage, 2)
    }
}
