import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private typealias CollectionViewSection = AnimatableSectionModel<String, PhotoCell.Model>
private typealias CollectionViewDataSource = RxCollectionViewSectionedAnimatedDataSource<CollectionViewSection>

final class SearchViewController: UIViewController {
    private weak var loadingFooter: LoadingFooter!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var fullScreenMessageLabel: UILabel!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!

    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()

    private let dataSource = CollectionViewDataSource(configureCell: {
        (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
        let cell = collectionView.dequeue(PhotoCell.self, for: indexPath)
        cell.configure(with: item)

        return cell
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupKeyboardDismissal()
        bindViewState()
        bindSearchBar()
        bindScrollView()
        bindCollectionView()
    }

    private func bindViewState() {
        viewModel.viewState.asObserver()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewState in
                guard let welf = self else { return }
                welf.configure(for: viewState)
            }).disposed(by: disposeBag)
    }

    private func bindSearchBar() {
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .empty)
            .drive(viewModel.searchText)
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .bind(onNext: dismissKeyboard)
            .disposed(by: disposeBag)
    }

    private func bindScrollView() {
        collectionView.rx.contentOffset
            .map {
                let bottomOffset = self.collectionView.contentSize.height - self.collectionView.bounds.size.height
                return $0.y == bottomOffset }
            .asDriver(onErrorJustReturn: false)
            .drive(viewModel.isScrolledToBottom)
            .disposed(by: disposeBag)

        collectionView.rx.willBeginDragging
            .bind(onNext: dismissKeyboard)
            .disposed(by: disposeBag)
    }

    private func bindCollectionView() {
        viewModel.items
            .observeOn(MainScheduler.instance)
            .map { return [AnimatableSectionModel(model: .empty, items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupCollectionView() {
        registerCellsAndFooter()
        setupCollectionViewLoadingFooter()
        setupCollectionViewLayout()
    }

    private func registerCellsAndFooter() {
        collectionView.register(PhotoCell.self)
        collectionView.register(LoadingFooter.self, for: UICollectionView.elementKindSectionFooter)
    }

    private func setupCollectionViewLayout() {
        let layoutBuilder = UICollectionViewLayoutBuilder()
        let flowLayout = layoutBuilder.flowLayout(itemsPerRow: 3, interitemSpacing: 10, inset: 10)
        collectionView.collectionViewLayout = flowLayout
    }

    private func setupCollectionViewLoadingFooter() {
        dataSource.configureSupplementaryView = { dataSource, collectionView, string, indexPath in
            guard string == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
            let loadingFooter = collectionView.dequeue(LoadingFooter.self,
                                                       at: indexPath,
                                                       for: UICollectionView.elementKindSectionFooter)
            self.loadingFooter = loadingFooter

            return loadingFooter
        }
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - View state configuration

extension SearchViewController {
    private func configure(for state: State) {
        switch state {
        case .empty: configureViewForEmptyState()
        case .noResult: configureViewForNoResultState()
        case .error(let errorMessage): configureViewForErrorState(message: errorMessage)
        case .loading(let stage): configureViewForLoadingState(stage: stage)
        case .loaded(let stage): configureViewForLoadedState(stage: stage)
        }
    }

    private func configureViewForEmptyState() {
        activityIndicator.isHidden = true
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "Start searching for a keyword"
    }

    private func configureViewForNoResultState() {
        activityIndicator.isHidden = true
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "There are no results\nTry searching for another word"
    }

    private func configureViewForErrorState(message: String) {
        activityIndicator.isHidden = true
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "Error occured\n\(message)"
    }

    private func configureViewForLoadingState(stage: State.LoadingStage) {
        fullScreenMessageLabel.isHidden = true
        switch stage {
        case .initial:
            activityIndicator.isHidden = false
            collectionView.isHidden = true
            activityIndicator.startAnimating()
        case .iterative:
            loadingFooter.startAnimating()
        }
    }

    private func configureViewForLoadedState(stage: State.LoadingStage) {
        fullScreenMessageLabel.isHidden = true
        switch stage {
        case .initial:
            activityIndicator.isHidden = true
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
            collectionView.scrollToItem(at: .init(row: 0, section: 0),
                                        at: .top, animated: false)
        case .iterative:
            loadingFooter.stopAnimating()
        }
    }
}
