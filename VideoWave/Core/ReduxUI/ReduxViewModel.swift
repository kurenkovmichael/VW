import Foundation
import Combine

class ReduxViewModel<ReduxState: Equatable, ReduxAction, ViewState, ViewAction>: ObservableObject {
    typealias ViewStateMapper = ReduxViewStateMapper<ReduxState, ReduxAction, ViewState, ViewAction>
    
    var viewState: ViewState
    
    init(store: Store<ReduxState, ReduxAction>, viewStateMapper: ViewStateMapper) {
        self.store = store
        self.viewStateMapper = viewStateMapper
        self.viewState = viewStateMapper.map(state: store.state)
        
        store.statePublisher
            .sink { [weak self] state in
                guard let slf = self else { return }
                slf.viewState = slf.viewStateMapper.map(state: state)
                slf.objectWillChange.send()
            }
            .store(in: &cancellable)
    }
    
    func dispatch(action: ViewAction) {
        if let coreAction = viewStateMapper.map(action: action) {
            store.dispatch(action: coreAction)
        }
    }
    
    private let store: Store<ReduxState, ReduxAction>
    private let viewStateMapper: ViewStateMapper
    private var cancellable = Set<AnyCancellable>()

}

open class ReduxViewStateMapper<ReduxState, ReduxAction, ViewState, ViewAction> {
    func map(state: ReduxState) -> ViewState {
        fatalError("Not Implemented")
    }
    
    func map(action: ViewAction) -> ReduxAction? {
        fatalError("Not Implemented")
    }
}

