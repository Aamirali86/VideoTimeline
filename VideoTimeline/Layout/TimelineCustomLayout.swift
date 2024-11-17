//
//  TimelineCustomLayout.swift
//  VideoTimeline
//
//  Created by Aamir on 17/11/2024.
//

import UIKit

final class TimelineCustomLayout: UICollectionViewLayout {
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = .zero
    
    var defaultItemWidth: CGFloat = 200
    var itemHeight: CGFloat = 80
    private var customWidths: [IndexPath: CGFloat] = [:]
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        layoutAttributes = []
        
        var xOffset: CGFloat = 0
        for index in 0..<itemCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let itemWidth = customWidths[indexPath] ?? defaultItemWidth
            attributes.frame = CGRect(x: xOffset, y: 0, width: itemWidth, height: itemHeight)
            xOffset += itemWidth
            layoutAttributes.append(attributes)
        }
        
        contentSize = CGSize(width: xOffset, height: itemHeight)
    }
    
    override var collectionViewContentSize: CGSize {
        contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributes[indexPath.item]
    }
}

// MARK: - Delegates
extension TimelineCustomLayout {
    func updateItemWidth(for indexPath: IndexPath, _ newWidth: CGFloat) {
        customWidths[indexPath] = newWidth
        invalidateLayout()
    }
    
    func itemWidth(for indexPath: IndexPath) -> CGFloat {
        customWidths[indexPath] ?? defaultItemWidth
    }
}
