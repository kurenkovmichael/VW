import Foundation

public final class Weak<T> {
    public let objectIdentifier: ObjectIdentifier
    public var didSet: (_ newValue: T?) -> Void = { _ in }
    
    private weak var _value: AnyObject?
    
    public init(_ value: T? = nil) {
        _value = value.map({ $0 as AnyObject })
        objectIdentifier = value.flatMap({ ObjectIdentifier($0 as AnyObject) }) ?? nilObjectIdentifier
    }
}

extension Weak {
    public var value: T? {
        get {
            return _value as? T
        }

        set {
            _value = newValue.map({ $0 as AnyObject })
            didSet(_value as? T) // важно, чтобы результат геттера совпадал с параметром didSet
        }
    }

    public func matches(_ object: T) -> Bool {
        return _value === (object as AnyObject)
    }

    public func matches(_ other: Weak<T>) -> Bool {
        return self._value === other._value
    }
}

fileprivate let nilObjectIdentifier = ObjectIdentifier(NSNull())
