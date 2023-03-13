import Foundation

public protocol Locking: AnyObject {
    func lock()
    func unlock()
}

extension Locking {
    @discardableResult
    public func synchronized<T>(_ block: () -> T) -> T {
        lock()

        defer {
            unlock()
        }

        return block()
    }


    @discardableResult
    public func synchronized<T>(_ block: () throws -> T) rethrows -> T {
        lock()

        defer {
            unlock()
        }

        return try block()
    }
}


extension NSLock: Locking {}
extension NSConditionLock: Locking {}
extension NSRecursiveLock: Locking {}
extension NSCondition: Locking {}

public final class NoLock: Locking {
    public init() {}
    public func lock() {}
    public func unlock() {}
}
