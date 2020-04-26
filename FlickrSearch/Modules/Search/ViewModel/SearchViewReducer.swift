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
            .subscribe(onNext: { (photos) in
                if photos.photos.isEmpty {
                    relay.accept((page: page,
                            viewState: .empty,
                            newPhotos: photos.photos))
                    return
                }
                relay.accept((page: nextPage,
                        viewState: .loaded(loadingStage),
                        newPhotos: photos.photos))
            }, onError: { (error) in
                guard let error = (error as? APIError) else { return }
                relay.accept((page: page, viewState: .error(error.description), newPhotos: []))
            }).disposed(by: disposeBag)

        return relay
    }
}
