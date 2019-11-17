import Foundation

class FunckCheck<T> {
    private(set) var wasCalled = false
    private(set) var arguments: T?

    func call(_ arguments: T) {
        wasCalled = true
        self.arguments = arguments
    }
}

final class ZeroArgumentsFuncCheck: FunckCheck<()> {
    func call() {
        super.call(())
    }
}
