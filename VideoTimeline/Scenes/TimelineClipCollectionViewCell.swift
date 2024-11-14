//
//  TimelineClipCollectionViewCell.swift
//  VideoTimeline
//
//  Created by Aamir on 13/11/2024.
//

import UIKit

final class TimelineClipCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimelineClipCollectionViewCell"
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 0
        clipsToBounds = true
        
        contentView.addSubview(numberLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with number: Int) {
        numberLabel.text = "\(number)"
    }
}
