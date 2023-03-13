//
//  VideoWavePlayingVideoCell.swift
//  VideoWave
//
//  Created by Mikhail Kurenkov on 14.02.2023.
//

import UIKit

final class VideoWavePlayingVideoCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    static func height() -> CGFloat { 210 }
    
    func render(videoId: String) {
        idLabel.text = String(videoId.suffix(4))
    }
    
    private let background = UIView()
    private let idLabel = UILabel()

}

private extension VideoWavePlayingVideoCell {
    
    enum Layout {
        static let margin: CGFloat = 0
        static let cornerRadius: CGFloat = 24
    }
    
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        
        background.addSubview(idLabel)
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.textAlignment = .center
        idLabel.textColor = .white

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: background.topAnchor, constant: -Layout.margin / 2),
            contentView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: -Layout.margin),
            contentView.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: Layout.margin / 2),
            contentView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: Layout.margin),
            
            background.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor),
            background.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor)
        ])
        
        background.backgroundColor = .darkGray
    }
    
}

