import UIKit

final class VideoWaveMVPViewController: UIViewController {

    required init(presenter: VideoWavePresenter) {
        self.presenter = presenter
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
            self?.presenter.didScroll(to: itemId)
        }
        
        feedView.onShowItemWithId = { [weak self] itemId in
            self?.presenter.didShowItem(with: itemId)
        }
        
        presenter.setView(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.willDislay()
    }
    
    private let presenter: VideoWavePresenter
    private let feedView = VideoWaveFeedView()

}

extension VideoWaveMVPViewController: VideoWaveView {
    
    func render(items: [VideoWaveFeedItem], options: VideoWaveFeedRenderOptions?) {
        feedView.render(items: items, options: options)
    }
    
}
