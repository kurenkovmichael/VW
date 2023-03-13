import Foundation
import Combine

open class Middleware<State: Equatable, Action> {
    typealias Dispatch = ((Action) -> Void)
    
    func reduce(next: @escaping Dispatch) -> Dispatch {
        return { action in
            next(action)
        }
    }
    
    func register(store: Store<State, Action>, in cancellable: inout Set<AnyCancellable>) {
    }
    
}
