import UIKit

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

    private lazy var presenter: SearchPresenterInput = { SearchPresenter(view: self) }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupsearchBar()
        setupCollectionView()
        presenter.viewDidLoad()
    }

    private func setupsearchBar() {
        searchBar.delegate = self
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(PhotoCell.self)
        collectionView.register(LoadingFooter.self, for: UICollectionView.elementKindSectionFooter)
    }

    private var collectionViewLayout: UICollectionViewFlowLayout {
        let itemsPerRow = 3
        let interitemSpacing: CGFloat = 10
        let inset: CGFloat = 10
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = interitemSpacing
        flowLayout.minimumLineSpacing = interitemSpacing
        flowLayout.sectionInset = .init(top: inset, left: inset, bottom: inset, right: inset)
        let spacing = inset * 2 + interitemSpacing * CGFloat(itemsPerRow - 1)
        let cellWidth = Int((collectionView.bounds.width - spacing) / CGFloat(itemsPerRow))
        flowLayout.itemSize = .init(width: cellWidth, height: cellWidth)
        flowLayout.footerReferenceSize = .init(width: collectionView.bounds.width, height: 50)

        return flowLayout
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
            case .loading(let stage): self?.configureViewForLoadingState(loadingStage: stage)
            case .loaded(let stage): self?.configureViewForLoadedState(loadingStage: stage)
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

    private func configureViewForLoadingState(loadingStage: State.LoadingStage) {
        fullScreenMessageLabel.isHidden = true
        switch loadingStage {
        case .initial:
            activityIndicator.isHidden = false
            collectionView.isHidden = true
            activityIndicator.startAnimating()
        case .iterative:
            loadingFooter.startAnimating()

        }
    }

    private func configureViewForLoadedState(loadingStage: State.LoadingStage) {
        fullScreenMessageLabel.isHidden = true
        switch loadingStage {
        case .initial:
            activityIndicator.isHidden = true
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        case .iterative(let indexPaths):
            loadingFooter.stopAnimating()
            collectionView.insertItems(at: indexPaths)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return presenter.cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PhotoCell.self, for: indexPath)
        cell.configure(with: presenter.cellModels[indexPath.row])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
        let loadingFooter = collectionView.dequeue(LoadingFooter.self,
                                                   at: indexPath,
                                                   for: UICollectionView.elementKindSectionFooter)
        self.loadingFooter = loadingFooter

        return loadingFooter
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOffset = collectionView.contentSize.height - collectionView.bounds.size.height
        if scrollView.contentOffset.y == bottomOffset { presenter.userDidScrollToBottom() }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchTextDidChange(text: searchText)
    }
}
