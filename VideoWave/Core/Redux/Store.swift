import Foundation
import Combine

final class Store<State: Equatable, Action> {
    
    public var statePublisher: AnyPublisher<State, Never> {
        return stateSubject.eraseToAnyPublisher()
    }
    
    public var state: State {
        return stateSubject.value
    }

    init(state: State,
         reducer: Reducer<State, Action>.Type,
         middlewares: [Middleware<State, Action>])
    {
        self.stateSubject = .init(state)
        self.reducer = reducer
        self.middlewares = middlewares
        
        for middleware in middlewares {
            middleware.register(store: self, in: &cancellable)
        }
        
        let reduce: (Action) -> Void = { [weak self] action in
            guard let slf = self else { return }
            let oldState = slf.stateSubject.value
            let newState = slf.reducer.reduce(state: oldState, action: action)
            if newState != oldState {
                slf.stateSubject.send(newState)
            }
        }
        
        let dispatch: (Action) -> Void = middlewares.reversed().reduce(reduce, { next, middleware in
            return middleware.reduce(next: next)
        })
        
        self.actionsSubject
            .sink(receiveCompletion: { _ in }, receiveValue: dispatch)
            .store(in: &cancellable)
    }
    
    func dispatch(action: Action) {
        actionsSubject.send(action)
    }
    
    private let reducer: Reducer<State, Action>.Type
    private let middlewares: [Middleware<State, Action>]
    
    private let stateSubject: CurrentValueSubject<State, Never>
    private let actionsSubject = PassthroughSubject<Action, Never> ()
    private var cancellable = Set<AnyCancellable>()

}
