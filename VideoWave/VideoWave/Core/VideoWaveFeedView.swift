import UIKit


struct VideoWaveFeedItem: Hashable {
    let id: String
    let content: VideoWaveFeedItemContent
}

enum VideoWaveFeedItemContent: Hashable {
    case loading
    case playingVideo
    case video
}

enum VideoWaveFeedRenderOptions {
    case scrollTo(itemId: String)
}

class VideoWaveFeedView: UIView {
    
    public var onScrollToItemWithId: ((String) -> Void)? = nil
    public var onShowItemWithId: ((String) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: tableView.topAnchor),
            leftAnchor.constraint(equalTo: tableView.leftAnchor),
            bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
        ])
        
        dataSource.defaultRowAnimation = .fade

        tableView.register(VideoWaveLoadingCell.self)
        tableView.register(VideoWavePlayingVideoCell.self)
        tableView.register(VideoWaveVideoCell.self)
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.decelerationRate = .init(rawValue: 0.9)
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        backgroundColor = .black
        
    }
    
    private enum Section {
        case singleSection
    }
    
    private let tableView = UITableView()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Section, VideoWaveFeedItem>(
        tableView: tableView,
        cellProvider: { [weak self] tableView, indexPath, item in
            switch item.content {
            case .loading:
                guard let cell: VideoWaveLoadingCell = tableView.dequeueCell(for: indexPath)
                else { return UITableViewCell() }
                
                cell.render(videoId: item.id)
                return cell
                
            case .playingVideo:
                guard let cell: VideoWavePlayingVideoCell = tableView.dequeueCell(for: indexPath)
                else { return UITableViewCell() }
                
                cell.render(videoId: item.id)
                return cell
                
            case .video:
                guard let cell: VideoWaveVideoCell = tableView.dequeueCell(for: indexPath)
                else { return UITableViewCell() }
                
                cell.render(videoId: item.id)
                return cell
            }
        }
    )
    
    private var autoScroll = false

}

extension VideoWaveFeedView {
    
    func render(items: [VideoWaveFeedItem], options: VideoWaveFeedRenderOptions? = nil) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.singleSection])
        snapshot.appendItems(items, toSection: .singleSection)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        switch options {
        case .scrollTo(let itemId):
            if let playingVideoIndex = items.firstIndex(where: { $0.id == itemId }) {
                autoScroll = true
                tableView.scrollToRow(at: IndexPath(item: playingVideoIndex, section: 0), at: .top, animated:  true)
            }
        case nil: break
        }
    }
    
}

extension VideoWaveFeedView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return UITableView.automaticDimension
        }
        
        switch item.content {
        case .loading: return VideoWaveLoadingCell.height()
        case .playingVideo: return VideoWavePlayingVideoCell.height()
        case .video: return VideoWaveVideoCell.height()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        self.onShowItemWithId?(item.id)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let targetCell = tableView.cellForRow(at: indexPath) else { return }
    
        autoScroll = true
        tableView.setContentOffset(contentOffset(for: targetCell), animated: true)
        self.onScrollToItemWithId?(item.id)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !autoScroll else { return }
        
        guard let cell = targetCell(for: scrollView.contentOffset) else { return }
        didScroll(to: cell)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        autoScroll = false

        guard let cell = targetCell(for: scrollView.contentOffset) else { return }
        tableView.setContentOffset(contentOffset(for: cell), animated: true)
        didScroll(to: cell)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        autoScroll = false

        guard let cell = targetCell(for: tableView.contentOffset) else { return }
        tableView.setContentOffset(contentOffset(for: cell), animated: true)
        didScroll(to: cell)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let cell = targetCell(for: targetContentOffset.pointee) else { return }
        targetContentOffset.pointee = contentOffset(for: cell)
    }
    
    private func targetCell(for targetOffset: CGPoint) -> UITableViewCell? {
        return tableView.visibleCells.first { cell in
            cell.frame.contains(CGPoint(
                x: targetOffset.x + cell.frame.width * 0.5,
                y: targetOffset.y + cell.frame.height * 0.75
            ))
        }
    }
    
    private func contentOffset(for cell: UITableViewCell) -> CGPoint {
        return CGPoint(
            x: cell.frame.origin.x - tableView.adjustedContentInset.left,
            y: cell.frame.origin.y - tableView.adjustedContentInset.top
        )
    }
    
    private func didScroll(to cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        self.onScrollToItemWithId?(item.id)
    }
    
}

