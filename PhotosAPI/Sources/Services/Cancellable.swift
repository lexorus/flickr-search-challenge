import Foundation
import MicroNetwork

public protocol Cancellable: class, AutoMockable {
    func cancel()
}

final class CancellableTask: Cancellable {
    private let task: NetworkTask

    init(task: NetworkTask) {
        self.task = task
    }

    func cancel() {
        task.cancel()
    }
}

final class EmptyCancellable: Cancellable {
    func cancel() {
        debugPrint("Nothing to cancel")
    }
}

extension NetworkTask {
    func toCancellable() -> Cancellable {
        return CancellableTask(task: self)
    }
}
