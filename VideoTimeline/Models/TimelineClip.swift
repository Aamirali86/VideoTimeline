//
//  TimelineClip.swift
//  VideoTimeline
//
//  Created by Aamir on 16/11/2024.
//

import UIKit

struct TimelineClip {
    let size: CGSize
    var colorBoxes: [UIColor]
    
    mutating func visibleColorBoxes(for width: CGFloat, itemWidth: CGFloat = 40) -> [UIColor] {
        let maxItems = Int(floor(width / itemWidth))
        
        if colorBoxes.count < maxItems {
            let additionalColors = (colorBoxes.count..<maxItems).map { _ in randomColor() }
            let allColors = colorBoxes + additionalColors
            colorBoxes = allColors
            return allColors
        }
        
        return Array(colorBoxes.prefix(maxItems))
    }
    
    private func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
