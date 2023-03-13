import Foundation

struct VideoWaveState: Equatable {
    let videos: [Video]
    let playingVideoId: String?
    
    static let initial: VideoWaveState = .init(videos: [], playingVideoId: nil)
}

enum VideoWaveAction {
    case willAppear
    case onScrollToItem(videoId: String)
    case onShowItem(videoId: String)
    case onLoadVideos(videos: [Video])
    case onStartPlayback(videoId: String)
    case onFinishPlayback(videoId: String)
}

final class VideoWaveReducer: Reducer<VideoWaveState, VideoWaveAction> {
    
    override class func reduce(state: VideoWaveState, action: VideoWaveAction) -> VideoWaveState {
        return .init(
            videos: reduce(videos: state.videos, action: action),
            playingVideoId: reduce(state: state, action: action)
        )
    }
    
    class func reduce(videos: [Video], action: VideoWaveAction) -> [Video] {
        switch action {
        case .onLoadVideos(let loadedVideos):
            return loadedVideos
            
        default:
            return videos
        }
    }
    
    class func reduce(state: VideoWaveState, action: VideoWaveAction) -> String? {
        switch action {
            
        case .onLoadVideos(let videos):
            if state.videos.isEmpty, let videoId = videos.first?.id {
                return videoId
            } else {
                return state.playingVideoId
            }
            
        case .onScrollToItem(let videoId):
            return videoId
        
        case .onStartPlayback(let videoId):
            return videoId
        
        case .onFinishPlayback(let videoId):
            if let index = state.videos.firstIndex(where: { $0.id == videoId }),
               let nextVideo = state.videos[safe: index + 1] {
                return nextVideo.id
            } else {
                return nil
            }
        
        default:
            return state.playingVideoId
            
        }
    }
}
