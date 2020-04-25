import PhotosAPI
import RxSwift
import RxRelay

protocol RxPhotosAPI {
    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt) -> Single<PhotosPage>
    func getImageData(for photo: Photo) -> Single<Data>
}

final class PhotosAPIRxAdapter: RxPhotosAPI {
    private let api: PhotosAPI

    init(photosAPI: PhotosAPI) {
        api = photosAPI
    }

    func getPhotos(query: String, pageNumber: UInt, pageSize: UInt) -> Single<PhotosPage> {
        return Single.create { observer in
            let callback: (Result<PhotosPage, APIError>) -> Void = { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            let cancellable = self.api.getPhotos(query: query,
                                                 pageNumber: pageNumber,
                                                 pageSize: pageSize,
                                                 callback: callback)

            return Disposables.create { cancellable.cancel() }
        }
    }

    func getImageData(for photo: Photo) -> Single<Data> {
        return Single.create { observer in
            let callback: (Result<Data, APIError>) -> Void = { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            let cancellable = self.api.getImageData(for: photo, callback: callback)

            return Disposables.create { cancellable.cancel() }
        }
    }
}

struct SearchPage {
    let query: String
    let size: UInt
    let number: UInt
    let totalNumberOfPages: UInt?

    var isFirst: Bool { return number == 1 }
    var isLast: Bool { number == totalNumberOfPages }
    var totalNumberOfItems: UInt { number * size }

    init(query: String,
         pageSize: UInt = 21,
         totalNumberOfPages: UInt? = nil,
         currentPage: UInt = 1) {
        self.query = query
        self.size = pageSize
        self.totalNumberOfPages = totalNumberOfPages
        self.number = currentPage
    }

    func next() -> SearchPage? {
        if isLast { return nil }
        return SearchPage(query: query,
                              pageSize: size,
                              totalNumberOfPages: totalNumberOfPages,
                              currentPage: number + 1)
    }
}

final class SearchViewStateReducer {
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
