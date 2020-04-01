import Foundation
import RxSwift

final class SearchViewModel {
    private let fetcher: FetcherType
    private let searchPhotosFetcher: SearchedPhotosFetcherType
    private let disposeBag = DisposeBag()

    let items = BehaviorSubject(value: [PhotoCell.Model]())
    let searchText = BehaviorSubject(value: "")
    let isScrolledToBottom = BehaviorSubject(value: false)

    init(fetcher: FetcherType = Fetcher(apiKey: "3e7cc266ae2b0e0d78e279ce8e361736"),
         searchPhotosFetcher: SearchedPhotosFetcherType? = nil) {
        // Internals init
        self.fetcher = fetcher
        self.searchPhotosFetcher = searchPhotosFetcher ?? SearchedPhotosFetcher(fetcher: fetcher)

        // Subscriptions
        searchText.asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: searchTextDidChange(text:))
            .disposed(by: disposeBag)

        isScrolledToBottom.asObserver()
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .subscribe(onNext: loadNextPage)
            .disposed(by: disposeBag)
    }

    private func searchTextDidChange(text: String) {
        print(text)
    }

    private func loadNextPage() {
        print("Next page should be loaded")
    }
}
