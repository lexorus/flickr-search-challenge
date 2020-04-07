import Foundation
import PhotosAPI

public final class MockCancellable: Cancellable {
    public var cancelFuncCheck = ZeroArgumentsFuncCheck()
    public func cancel() {
        cancelFuncCheck.call()
    }

    public init() {}
}
