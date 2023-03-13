import Foundation
import Combine

class EpicMiddleware<State: Equatable, Action>: Middleware<State, Action> {
    
    init(epics: [Epic<State, Action>]) {
        self.epics = epics
    }
    
    override func reduce(next: @escaping Dispatch) -> Dispatch {
        return { [weak self] action in
            next(action)
            self?.actions.send(action)
        }
    }
    
    override func register(store: Store<State, Action>, in cancellable: inout Set<AnyCancellable>) {
        for epic in epics {
            epic.act(store: store, actions: actions.eraseToAnyPublisher())
                .sink { store.dispatch(action: $0) }
                .store(in: &cancellable)
        }
    }
    
    private let epics: [Epic<State, Action>]
    private let actions = PassthroughSubject<Action, Never>()
    private var store: Store<State, Action>? = nil
    private var cancellable = Set<AnyCancellable>()

}
