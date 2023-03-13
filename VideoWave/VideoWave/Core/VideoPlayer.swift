import Foundation

protocol VideoPlayerListner {
    func didStartPlayback(videoId: String)
    func didFinishPlayback(videoId: String)
    func didStopPlayback(videoId: String)
}

protocol VideoPlayer {
    var playingVideoId: String? { get }
    func play(videoId: String)
    func stop()
    func add(listner: VideoPlayerListner)
    func remove(listner: VideoPlayerListner)
}

class VideoPlayerImpl {
    private(set) var playingVideoId: String?
    private let listners = WeakSequence<VideoPlayerListner>()
    private var playbackDispatchWorkItem: DispatchWorkItem? = nil
}

extension VideoPlayerImpl: VideoPlayer {
    
    func play(videoId: String) {
        stop()
        
        playingVideoId = videoId
        listners.forEach { $0.didStartPlayback(videoId: videoId) }
        
        let playback = DispatchWorkItem { [weak self] in
            guard self?.playingVideoId == videoId else { return }
            
            self?.playbackDispatchWorkItem = nil
            self?.playingVideoId = nil
            self?.listners.forEach { $0.didFinishPlayback(videoId: videoId) }
        }
        playbackDispatchWorkItem = playback
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: playback)
    }
    
    func stop() {
        guard let videoId = playingVideoId else { return }
        
        playbackDispatchWorkItem?.cancel()
        playbackDispatchWorkItem = nil
        playingVideoId = nil
        listners.forEach { $0.didStopPlayback(videoId: videoId) }
    }
    
    func add(listner: VideoPlayerListner) {
        listners.add(listner)
    }
    
    func remove(listner: VideoPlayerListner) {
        listners.remove(listner)
    }
}
