import Foundation

final class Atomic<T> {
    private var _value: T
    private let lock = NSLock()

    init(_ value: T) {
        self._value = value
    }

    var value: T {
        get {
            lock.lock()
            let result = _value
            lock.unlock()
            return result
        }
        set {
            lock.lock()
            _value = newValue
            lock.unlock()
        }
    }
}
