import Foundation
import Combine

final class VideoWavePreloadEpic: Epic<VideoWaveState, VideoWaveAction> {
    
    init(repository: VideoRepository) {
        self.repository = repository
        super.init()
        
        repository.add(listner: self)
    }
    
    override func act(acton: VideoWaveAction) -> VideoWaveAction? {
        switch acton {
        case .willAppear:
            self.repository.loadNextVideo()
        
        case .onShowItem(let videoId):
            if let index = self.repository.videos.firstIndex(where: { $0.id == videoId }),
               index > self.repository.videos.count - 3
            {
                self.repository.loadNextVideo()
            }
            
        default:
            break
        }

        return nil
    }
    
    private let repository: VideoRepository

}

extension VideoWavePreloadEpic: VideoRepositoryListner {
    
    func didChangeVideos() {
        let videos = repository.videos
        store?.dispatch(action: .onLoadVideos(videos: videos))
    }

}
