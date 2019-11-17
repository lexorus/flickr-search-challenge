import Foundation
@testable import FlickrSearchChallenge

final class MockCancellable: Cancellable {
    var cancelFuncCheck = ZeroArgumentsFuncCheck()
    func cancel() {
        cancelFuncCheck.call()
    }
}
