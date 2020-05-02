import PhotosAPI
import RxSwift
import RxRelay

final class SearchViewReducer {
    private let api: RxPhotosAPI = PhotosAPIRxAdapter(photosAPI: FlickrPhotosAPI(key: "3e7cc266ae2b0e0d78e279ce8e361736"))
    private var disposeBag = DisposeBag()

    func reduce(page: SearchPage, viewState: SearchViewController.State, photos: [Photo]) -> BehaviorRelay<(page: SearchPage, viewState: SearchViewController.State, newPhotos: [Photo])> {
        if page.query.isEmpty {
            return .init(value: (page: page, viewState: .empty, newPhotos: []))
        }
        guard let nextPage = page.next() else {
            return .init(value: (page: page, viewState: viewState, newPhotos: []))
        }

        let loadingStage: SearchViewController.State.LoadingStage = page.isFirst ? .initial : .iterative
        let relay = BehaviorRelay<(page: SearchPage, viewState: SearchViewController.State, newPhotos: [Photo])>(value: (page: page, viewState: .loading(loadingStage), newPhotos: photos))
        api.getPhotos(query: nextPage.query,
                      pageNumber: nextPage.number,
                      pageSize: nextPage.size)
            .asObservable()
            .subscribe(onNext: { (newPhotosPage) in
                if newPhotosPage.photos.isEmpty {
                    relay.accept((page: page,
                                  viewState: .empty,
                                  newPhotos: newPhotosPage.photos))
                    return
                }
                let newPhotos = newPhotosPage.photos
                    .removingDuplicates(existingIds: photos.map(\.id))
                switch loadingStage {
                case .initial:
                    relay.accept((page: nextPage,
                                  viewState: .loaded(loadingStage),
                                  newPhotos: newPhotos))
                case .iterative:
                    relay.accept((page: nextPage,
                                  viewState: .loaded(loadingStage),
                                  newPhotos: photos + newPhotos))
                }

                relay.accept((page: nextPage,
                        viewState: .loaded(loadingStage),
                        newPhotos: newPhotosPage.photos))
            }, onError: { (error) in
                guard let error = (error as? APIError) else { return }
                relay.accept((page: page, viewState: .error(error.description), newPhotos: []))
            }).disposed(by: disposeBag)

        return relay
    }
}

private extension Array where Element == Photo {
    // Noticed that Flickr can return multiple photos with the same id in one response.
    // Which will break the animated collection logic and may lead to crash.
    // It also does make sense to show identical photos for one query.
    // This surely affects performance, but since we are working with small datasets
    // it shouldn't be visible.
    func removingDuplicates(existingIds: [String] = []) -> [Photo] {
        let existingIdsSet = Set(existingIds)
        let newPhotosRemovingExisting = filter { !existingIdsSet.contains($0.id) }
        var idsSet = Set<String>()
        return newPhotosRemovingExisting.reduce([]) { acc, element in
            if idsSet.contains(element.id) { return acc }
            idsSet.insert(element.id)
            return acc + [element]
        }
    }
}
