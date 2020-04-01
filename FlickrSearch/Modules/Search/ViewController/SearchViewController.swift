import UIKit
import RxSwift
import RxCocoa

protocol SearchPresenterOutput: class {
    func configure(for state: SearchViewController.State)
}

protocol SearchPresenterInput {
    var cellModels: [PhotoCell.Model] { get }
    func viewDidLoad()
    func searchTextDidChange(text: String)
    func userDidScrollToBottom()
}

final class SearchViewController: UIViewController {
    private weak var loadingFooter: LoadingFooter!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var fullScreenMessageLabel: UILabel!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!

    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewState()
        bindSearchBar()
        bindScrollView()
        setupCollectionView()
        bindCollectionView()
        setupKeyboardDismissal()
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
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
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
            .asObservable()
            .bind(to: self.collectionView.rx.items(cellIdentifier: PhotoCell.id, cellType: PhotoCell.self)) { row, data, cell in
                cell.configure(with: data)
        }.disposed(by: disposeBag)
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(PhotoCell.self)
        collectionView.register(LoadingFooter.self, for: UICollectionView.elementKindSectionFooter)
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

// MARK: - SearchPresenterOutput

extension SearchViewController: SearchPresenterOutput {
    func configure(for state: State) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .empty: self?.configureViewForEmptyState()
            case .noResult: self?.configureViewForNoResultState()
            case .error(let errorMessage): self?.configureViewForErrorState(message: errorMessage)
            case .loading(let stage): self?.configureViewForLoadingState(stage: stage)
            case .loaded(let stage): self?.configureViewForLoadedState(stage: stage)
            }
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

//// MARK: - UICollectionViewDataSource
//
//extension SearchViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        return presenter.cellModels.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeue(PhotoCell.self, for: indexPath)
//        cell.configure(with: presenter.cellModels[indexPath.row])
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//        guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
//        let loadingFooter = collectionView.dequeue(LoadingFooter.self,
//                                                   at: indexPath,
//                                                   for: UICollectionView.elementKindSectionFooter)
//        self.loadingFooter = loadingFooter
//
//        return loadingFooter
//    }
//}

// MARK: UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    private var itemsPerRow: Int { 3 }
    private var interitemSpacing: CGFloat { 10 }
    private var inset: CGFloat { 10 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = inset * 2 + interitemSpacing * CGFloat(itemsPerRow - 1)
        let cellWidth = Int((collectionView.bounds.width - spacing) / CGFloat(itemsPerRow))
        return .init(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 50)
    }
}
