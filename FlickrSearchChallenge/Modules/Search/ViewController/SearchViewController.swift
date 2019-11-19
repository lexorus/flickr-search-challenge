import UIKit

protocol SearchPresenterOutput {
    func configure(with state: SearchViewController.State)
}

#warning("To Remove: MockCellModels for UI testing until we have real data source.")
var cellModels = [0, 1, 2, 3, 4, 5]

final class SearchViewController: UIViewController {
    private weak var loadingFooter: LoadingFooter!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var fullScreenMessageLabel: UILabel!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupsearchBar()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #warning("To Remove: Data flow and UI update simulation until we have real data source.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.configure(with: .loading(.iterative([])))
            cellModels += [6, 7, 8]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.configure(with: .loaded(.iterative([
                    IndexPath(row: 6, section: 0),
                    IndexPath(row: 7, section: 0),
                    IndexPath(row: 8, section: 0)])))
            }
        }
    }

    private func setupsearchBar() {
        searchBar.delegate = self
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
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
    func configure(with state: State) {
        switch state {
        case .empty: configureViewForEmptyState()
        case .noResult: configureViewForNoResultState()
        case .error(let errorMessage): configureViewForErrorState(message: errorMessage)
        case .loading(let stage): configureViewForLoadingState(loadingStage: stage)
        case .loaded(let stage): configureViewForLoadedState(loadingStage: stage)
        }
    }

    private func configureViewForEmptyState() {
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "Start searching for a keyword"
    }

    private func configureViewForNoResultState() {
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "There are no results\nTry searching for another word"
    }

    private func configureViewForErrorState(message: String) {
        fullScreenMessageLabel.isHidden = false
        fullScreenMessageLabel.text = "Error occured\n\(message)"
    }

    private func configureViewForLoadingState(loadingStage: State.LoadingStage) {
        fullScreenMessageLabel.isHidden = true
        switch loadingStage {
        case .initial:
            activityIndicator.isHidden = false
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
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PhotoCell.self, for: indexPath)
        cell.configure()

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

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        #warning("To Update: We should pass the text to the buisiness logic once implemented.")
        print(searchText)
    }
}
