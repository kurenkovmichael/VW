import UIKit
import Combine

protocol VideoWaveUDFViewControllerDeps {
    var repository: VideoRepository { get }
    var videoPlayer: VideoPlayer { get }
}

final class VideoWaveUDFViewController: UIViewController {
    
    required init(deps: VideoWaveUDFViewControllerDeps) {
        self.store = .init(
            state: .initial,
            reducer: VideoWaveReducer.self,
            middlewares: [
                EpicMiddleware(epics: [
                    VideoWavePreloadEpic(repository: deps.repository),
                    VideoWavePlayerEpic(videoPlayer: deps.videoPlayer)
                ])
            ]
        )
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(feedView)
        feedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: feedView.topAnchor),
            view.leftAnchor.constraint(equalTo: feedView.leftAnchor),
            view.bottomAnchor.constraint(equalTo: feedView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: feedView.trailingAnchor)
        ])
        
        feedView.onScrollToItemWithId = { [weak self] itemId in
            self?.store.dispatch(action: .onScrollToItem(videoId: itemId))
        }
        
        feedView.onShowItemWithId = { [weak self] itemId in
            self?.store.dispatch(action: .onShowItem(videoId: itemId))
        }
        
        store.statePublisher
            .sink { [weak self] state in self?.render(state: state) }
            .store(in: &cancellable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.dispatch(action: .willAppear)
    }
    
    private let feedView = VideoWaveFeedView()
    private let store: Store<VideoWaveState, VideoWaveAction>
    private var cancellable = Set<AnyCancellable>()

}

private extension VideoWaveUDFViewController {
    
    func render(state: VideoWaveState) {
        let items = state.videos.map { video in
            VideoWaveFeedItem(
                id: video.id,
                content: (video.id == state.playingVideoId)
                ? .playingVideo
                : (video.loaded ? .video : .loading)
            )
        }
        
        let options = state.playingVideoId.flatMap {
            VideoWaveFeedRenderOptions.scrollTo(itemId: $0)
        }
        
        feedView.render(items: items, options: options)
    }
    
}
