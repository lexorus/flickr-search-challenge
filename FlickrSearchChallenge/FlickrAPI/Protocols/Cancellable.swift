import Foundation

protocol Cancellable {
    func cancel()
}

extension URLSessionDataTask: Cancellable {}
