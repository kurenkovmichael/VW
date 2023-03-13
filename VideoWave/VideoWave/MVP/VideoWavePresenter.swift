import Foundation

protocol VideoWaveView: AnyObject {
    func render(items: [VideoWaveFeedItem], options: VideoWaveFeedRenderOptions?)
}

final class VideoWavePresenter {
    
    init(repository: VideoRepository, videoPlayer: VideoPlayer) {
        self.repository = repository
        self.videoPlayer = videoPlayer
        
        videoPlayer.add(listner: self)
        repository.add(listner: self)
    }
    
    private let repository: VideoRepository
    private let videoPlayer: VideoPlayer
    private weak var view: VideoWaveView?
    
}

extension VideoWavePresenter {
    
    func setView(_ view: VideoWaveView) {
        self.view = view
    }
    
    func willDislay() {
        if let videoId = repository.videos.first?.id {
            videoPlayer.play(videoId: videoId)
        }
        render()
    }
    
    func didScroll(to itemId: String) {
        guard videoPlayer.playingVideoId != itemId else { return }
        videoPlayer.play(videoId: itemId)
        render()
    }
    
    func didShowItem(with itemId: String) {
        guard let index = repository.videos.firstIndex(where: { $0.id == itemId }) else { return }

        if index > repository.videos.count - 3 {
            repository.loadNextVideo()
        }
    }
    
}

private extension VideoWavePresenter {
    
    private func mapVideo(_ video: Video) -> VideoWaveFeedItem {
        return VideoWaveFeedItem(
            id: video.id,
            content: (video.id == videoPlayer.playingVideoId)
                ? .playingVideo
                : (video.loaded ? .video : .loading)
        )
    }
    
    private func render(options: VideoWaveFeedRenderOptions? = nil) {
        let items = repository.videos.map { mapVideo($0) }
        view?.render(items: items, options: options)
    }
    
}

extension VideoWavePresenter: VideoRepositoryListner {
    
    func didChangeVideos() {
        render()
    }

}

extension VideoWavePresenter: VideoPlayerListner {
    
    func didStartPlayback(videoId: String) {
    }
    
    func didFinishPlayback(videoId: String) {
        if let index = repository.videos.firstIndex(where: { $0.id == videoId }),
           let nextVideo = repository.videos[safe: index + 1] {
            videoPlayer.play(videoId: nextVideo.id)
            render(options: .scrollTo(itemId: nextVideo.id))
        }
    }    
    
    func didStopPlayback(videoId: String) {
    }
    
}
