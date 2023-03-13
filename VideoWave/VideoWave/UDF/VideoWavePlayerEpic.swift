import Foundation
import Combine

final class VideoWavePlayerEpic: Epic<VideoWaveState, VideoWaveAction> {
    
    init(videoPlayer: VideoPlayer) {
        self.videoPlayer = videoPlayer
        super.init()
        
        videoPlayer.add(listner: self)
    }
    
    override func act(state: VideoWaveState) -> VideoWaveAction? {
        guard state.playingVideoId != videoPlayer.playingVideoId else { return nil }
        if let videoId = state.playingVideoId {
            videoPlayer.play(videoId: videoId)
        } else {
            videoPlayer.stop()
        }
        return nil
    }
    
    private let videoPlayer: VideoPlayer

}

extension VideoWavePlayerEpic: VideoPlayerListner {
    
    func didStartPlayback(videoId: String) {
        store?.dispatch(action: .onStartPlayback(videoId: videoId))
    }
    
    func didFinishPlayback(videoId: String) {
        store?.dispatch(action: .onFinishPlayback(videoId: videoId))
    }
    
    func didStopPlayback(videoId: String) {
    }
    
}
