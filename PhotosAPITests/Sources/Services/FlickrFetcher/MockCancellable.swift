import Foundation
@testable import PhotosAPI

final class MockCancellable: Cancellable {
    var cancelFuncCheck = ZeroArgumentsFuncCheck()
    func cancel() {
        cancelFuncCheck.call()
    }
}
