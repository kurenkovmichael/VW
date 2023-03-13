import Foundation
import Combine

open class Epic<State: Equatable, Action>  {
    
    func act(store: Store<State, Action>, actions: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> {
        self.store = store
        return store.statePublisher.compactMap { [weak self] state in self?.act(state: state) }
            .merge(with: actions.compactMap { [weak self] action in self?.act(acton: action) })
            .eraseToAnyPublisher()
    }
    
    func act(state: State) -> Action? {
        return nil
    }
    
    func act(acton: Action) -> Action? {
        return nil
    }
    
    var store: Store<State, Action>? = nil

}
