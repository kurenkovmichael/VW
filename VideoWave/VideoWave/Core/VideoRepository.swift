import Foundation

struct Video: Equatable {
    let id: String
    let loaded: Bool
}

protocol VideoRepositoryListner {
    func didChangeVideos()
}

protocol VideoRepository {
    var videos: [Video] { get }
    func loadNextVideo()
    func add(listner: VideoRepositoryListner)
    func remove(listner: VideoRepositoryListner)
}

final class VideoRepositoryImpl {

    private(set) var videos: [Video] = [
        .init(id: UUID().uuidString, loaded: true),
        .init(id: UUID().uuidString, loaded: true),
        .init(id: UUID().uuidString, loaded: true)
    ]

    private let listners = WeakSequence<VideoRepositoryListner>()
    
}

extension VideoRepositoryImpl: VideoRepository {
    
    func loadNextVideo() {
        let id = UUID().uuidString

        DispatchQueue.main.async {
            self.videos.append(.init(id: id, loaded: false))
            self.listners.forEach { $0.didChangeVideos() }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.videos = self.videos.map { Video(id: $0.id, loaded: ($0.id == id) ? true : $0.loaded) }
            self.listners.forEach { $0.didChangeVideos() }
        }
    }
    
    func add(listner: VideoRepositoryListner) {
        listners.add(listner)
    }
    
    func remove(listner: VideoRepositoryListner) {
        listners.remove(listner)
    }
    
}
