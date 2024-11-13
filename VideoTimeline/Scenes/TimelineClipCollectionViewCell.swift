//
//  TimelineClipCollectionViewCell.swift
//  VideoTimeline
//
//  Created by Aamir on 13/11/2024.
//

import UIKit

final class TimelineClipCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimelineClipCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 0
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
