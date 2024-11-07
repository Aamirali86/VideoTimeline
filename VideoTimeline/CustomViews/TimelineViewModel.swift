//
//  TimelineViewModel.swift
//  VideoTimeline
//
//  Created by Aamir on 07/11/2024.
//

import Foundation

final class TimelineViewModel {
    var currentScale: CGFloat = 1.0 {
        didSet {
            updateScale?()
        }
    }
    
    var updateScale: (() -> Void)?
    
    func handlePinchGesture(scale: CGFloat, _ currentScale: CGFloat) {
        var newScale = scale * currentScale
        
        // Prevent zooming out below the original size
        if newScale < 1.0 {
            newScale = 1.0
        }
        
        // Prevent zooming beyond a maximum scale
        let maxScale: CGFloat = 1.5
        if newScale > maxScale {
            newScale = maxScale
        }
        self.currentScale = newScale
    }
}
