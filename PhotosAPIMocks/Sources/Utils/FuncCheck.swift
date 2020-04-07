import Foundation

open class FuncCheck<T> {
    public private(set) var wasCalled = false
    public private(set) var arguments: T?
    public private(set) var callCount = 0

    open func call(_ arguments: T) {
        wasCalled = true
        callCount += 1
        self.arguments = arguments
    }

    open func reset() {
        wasCalled = false
        arguments = nil
        callCount = 0
    }

    public init() {}
}

extension FuncCheck where T: Equatable {
    public func wasCalled(with argumets: T) -> Bool {
        return wasCalled && self.arguments == arguments
    }
}

public final class ZeroArgumentsFuncCheck: FuncCheck<()> {
    public func call() {
        super.call(())
    }
}
