import Foundation

class FuncCheck<T> {
    private(set) var wasCalled = false
    private(set) var arguments: T?
    private(set) var callCount = 0

    func call(_ arguments: T) {
        wasCalled = true
        callCount += 1
        self.arguments = arguments
    }

    func reset() {
        wasCalled = false
        arguments = nil
        callCount = 0
    }
}

extension FuncCheck where T: Equatable {
    func wasCalled(with argumets: T) -> Bool {
        return wasCalled && self.arguments == arguments
    }
}

final class ZeroArgumentsFuncCheck: FuncCheck<()> {
    func call() {
        super.call(())
    }
}
