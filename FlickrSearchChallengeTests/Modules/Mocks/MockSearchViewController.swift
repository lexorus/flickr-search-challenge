import Foundation
@testable import FlickrSearch

final class MockSearchViewController: SearchPresenterOutput {
    var configureFuncCheck = FuncCheck<SearchViewController.State>()
    func configure(for state: SearchViewController.State) {
        configureFuncCheck.call(state)
    }
}
