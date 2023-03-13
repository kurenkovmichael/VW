import Foundation

public final class WeakSequence<T>: Sequence {
    private let lock = NSRecursiveLock()

    private var _orderedRefs = [Weak<T>]()
    private var _registeredRefs: [ObjectIdentifier: Weak<T>] = [:]

    public init() {}
}

extension WeakSequence {
    
    public func add(_ object: T) {
        lock.synchronized {
            let ref = Weak(object)

            guard false == _isRegistered(ref) else {
                return
            }

            _orderedRefs.append(ref)
            _registerRef(ref)
        }
    }

    public func remove(_ object: T) {
        lock.synchronized {
            // Избегаем создания `Weak(object)` здесь, т.к. если метод `remove` вызывается
            // из `deinit` объекта, который мы пытаемся удалить, рантайм Swift вызывает
            // assertion failure – нельзя создавать слабую ссылку на объект в процессе деаллокации.
            _orderedRefs = _orderedRefs.filter { $0.value != nil && false == $0.matches(object) }
            _registeredRefs[ObjectIdentifier(object as AnyObject)] = nil
        }
    }

    public func contains(_ object: T) -> Bool {
        return lock.synchronized {
            let ref = Weak(object)
            return _isRegistered(ref)
        }
    }

    public func makeIterator() -> AnyIterator<T> {
        return lock.synchronized {
            _pruneNilRefs()
            let objects = Array(_orderedRefs.compactMap({ $0.value }))
            return AnyIterator(objects.makeIterator())
        }
    }
}


extension WeakSequence: CustomStringConvertible {
    public var description: String {
        return lock.synchronized {
            String(describing: _orderedRefs.compactMap({ $0.value }))
        }
    }
}


extension WeakSequence {
    /// Регистрирует обертку `Weak<T>`, чтобы можно было проводить
    /// проверку существования за O(1).
    private func _registerRef(_ ref: Weak<T>) {
        let identifier = ref.objectIdentifier

        assert(
            _registeredRefs[identifier] == nil || _registeredRefs[identifier]?.value == nil,
            "по ключу уже зарегистрирован объект"
        )

        _registeredRefs[identifier] = ref
    }

    /// Проверяет, зарегистрирована ли обертка `Weak<T>`.
    private func _isRegistered(_ ref: Weak<T>) -> Bool {
        guard let existingRef = _registeredRefs[ref.objectIdentifier] else {
            return false
        }

        // Здесь может быть `false`, если ранее был зарегистрирован объект по ключу
        // `ref.objectIdentifier`, который был после этого деаллоцирован, и теперь
        // к нам пришел новый объект, лежащий по тому же адресу (у него будет такой
        // же `objectIdentifier`, но в `existingRef` будет лежать `nil`.
        let existingRefMatches = existingRef.matches(ref)

        assert(
            existingRefMatches || existingRef.value == nil,
            "по существующему ключу зарегистрирован другой ненулевой объект"
        )

        return existingRefMatches
    }

    private func _pruneNilRefs() {
        _registeredRefs = _registeredRefs.filter { $0.value.value != nil }
        _orderedRefs = _orderedRefs.filter { $0.value != nil }
    }
}
