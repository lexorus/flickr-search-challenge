import Foundation

protocol Cancellable {
    func cancel()
}

struct EmptyCancellable: Cancellable {
    func cancel() {
        debugPrint("Nothing to cancel")
    }
}

extension URLSessionDataTask: Cancellable {}
