import Foundation

protocol Cancellable: class {
    func cancel()
}

final class EmptyCancellable: Cancellable {
    func cancel() {
        debugPrint("Nothing to cancel")
    }
}

extension URLSessionDataTask: Cancellable {}
