import Foundation
@testable import FlickrSearchChallenge

final class MockSearchedPhotosFetcher: SearchedPhotosFetcherType {

    var fetcher: FetcherType
    init(fetcher: FetcherType) {
        self.fetcher = fetcher
    }

    var searchPhotosInfo: (searchString: String, paginator: Paginator)?

    var loadFirstPageFuncCheck = FuncCheck<(String, (SearchedPhotosFetcher.Result) -> Void)>()
    func loadFirstPage(for text: String, callback: @escaping (SearchedPhotosFetcher.Result) -> Void) {
        loadFirstPageFuncCheck.call((text, callback))
    }

    var loadNextPageFuncCheck = FuncCheck<((SearchedPhotosFetcher.Result) -> Void)>()
    func loadNextPage(callback: @escaping (SearchedPhotosFetcher.Result) -> Void) {
        loadNextPageFuncCheck.call(callback)
    }
}
