import Foundation

extension SearchViewController {
    enum State {
        case empty
        case noResult
        case error(String)
        case loading(LoadingStage)
        case loaded(LoadingStage)

        enum LoadingStage {
            case initial, iterative([IndexPath])
        }
    }
}
