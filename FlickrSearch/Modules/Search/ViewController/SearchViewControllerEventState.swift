import Foundation

extension SearchViewController {
    enum Event {
        case searchTextDidChange(String)
        case didScrolledToButtom
    }

    enum State: Equatable {
        case empty
        case noResult
        case error(String)
        case loading(LoadingStage)
        case loaded(LoadingStage)

        enum LoadingStage: Equatable {
            case initial, iterative
        }
    }
}
