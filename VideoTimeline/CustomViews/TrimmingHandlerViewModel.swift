//
//  TrimmingHandlerViewModel.swift
//  VideoTimeline
//
//  Created by Aamir on 07/11/2024.
//

import Foundation

final class TrimmingHandlerViewModel {
    private(set) var startValue: CGFloat = 0 {
        didSet {
            startValue = max(0, min(startValue, endValue - minimumTrimLength))
        }
    }
    
    private(set) var endValue: CGFloat = 1 {
        didSet {
            endValue = max(startValue + minimumTrimLength, min(endValue, 1))
        }
    }

    // Minimum distance between handlers to avoid intersaction
    let minimumTrimLength: CGFloat = 0.2

    func updateStartValue(to value: CGFloat) {
        startValue = value
    }

    func updateEndValue(to value: CGFloat) {
        endValue = value
    }
}
