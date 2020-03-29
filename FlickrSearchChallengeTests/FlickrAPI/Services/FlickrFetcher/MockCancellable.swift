import Foundation
@testable import FlickrSearch

final class MockCancellable: Cancellable {
    var cancelFuncCheck = ZeroArgumentsFuncCheck()
    func cancel() {
        cancelFuncCheck.call()
    }
}
