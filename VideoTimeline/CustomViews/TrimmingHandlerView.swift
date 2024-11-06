//
//  TrimmingHandlerView.swift
//  VideoTimeline
//
//  Created by Aamir on 06/11/2024.
//

import Foundation
import UIKit

final class TrimmingHandlerView: UIView {
    var minimumValue: CGFloat = 0
    var maximumValue: CGFloat = 1

    var startValue: CGFloat = 0 {
        didSet { updateLayout() }
    }
        
    var endValue: CGFloat = 1 {
        didSet { updateLayout() }
    }

    private let topBoundaryLayer = CALayer()
    private let bottomBoundaryLayer = CALayer()
    private let startThumbView = UIView()
    private let endThumbView = UIView()
    private var isTouchingStartThumb = false
    private var isTouchingEndThumb = false
    
    private let handleWidth: CGFloat = 20.0
    private let handleHeight: CGFloat = 64.0
    // Minimum distance between handlers to avoid intersaction
    private let minimumTrimLength: CGFloat = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
}

// MARK: UI Setup
private extension TrimmingHandlerView {
    func setupLayers() {
        topBoundaryLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(topBoundaryLayer)
        
        bottomBoundaryLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(bottomBoundaryLayer)
        
        startThumbView.backgroundColor = UIColor.white
        addSubview(startThumbView)
        
        endThumbView.backgroundColor = UIColor.white
        addSubview(endThumbView)
        
        updateFrames()
        addImage(handle: startThumbView, leading: true)
        addImage(handle: endThumbView, leading: false)
    }
    
    func addImage(handle: UIView, leading: Bool) {
        let arrowImageView = UIImageView()
        arrowImageView.tintColor = .lightGray
        arrowImageView.isUserInteractionEnabled = false
        arrowImageView.image = leading ? UIImage(systemName: "chevron.compact.left") : UIImage(systemName: "chevron.compact.right")
        handle.addSubview(arrowImageView)
        
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: handle.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: handle.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func updateFrames() {
        let startThumb = positionForValue(startValue)
        let endThumb = positionForValue(endValue)
        
        // Disable implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        startThumbView.frame = CGRect(x: startThumb, y: 0, width: handleWidth, height: handleHeight)
        endThumbView.frame = CGRect(x: endThumb - handleWidth, y: 0, width: handleWidth, height: handleHeight)
        
        let boundaryWidth = endThumb - startThumb
        topBoundaryLayer.frame = CGRect(x: startThumb, y: 0, width: boundaryWidth, height: 4)
        bottomBoundaryLayer.frame = CGRect(x: startThumb, y: bounds.height, width: boundaryWidth, height: 4)
        
        CATransaction.commit()
    }
    
    func updateLayout() {
        let start = positionForValue(startValue)
        let end = positionForValue(endValue)
        frame.origin.x = start
        frame.size.width = end - start
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        bounds.width * (value - minimumValue) / (maximumValue - minimumValue)
    }

    func valueForPosition(_ position: CGFloat) -> CGFloat {
        minimumValue + (maximumValue - minimumValue) * position / bounds.width
    }
}

// MARK: Gesture handler
extension TrimmingHandlerView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if startThumbView.frame.contains(touchLocation) {
            isTouchingStartThumb = true
        } else if endThumbView.frame.contains(touchLocation) {
            isTouchingEndThumb = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isTouchingStartThumb {
            let newValue = valueForPosition(touchLocation.x)
            // Ensure start is always less than end and greater then 0
            startValue = max(0, min(newValue, endValue - minimumTrimLength))
            
            startThumbView.backgroundColor = .yellow
            endThumbView.backgroundColor = .yellow
            topBoundaryLayer.backgroundColor = UIColor.yellow.cgColor
            bottomBoundaryLayer.backgroundColor = UIColor.yellow.cgColor
        } else if isTouchingEndThumb {
            let newValue = valueForPosition(touchLocation.x)
            // Ensure end is always greater than start and less then 1
            endValue = min(1, max(newValue, startValue + minimumTrimLength))
            
            startThumbView.backgroundColor = .yellow
            endThumbView.backgroundColor = .yellow
            topBoundaryLayer.backgroundColor = UIColor.yellow.cgColor
            bottomBoundaryLayer.backgroundColor = UIColor.yellow.cgColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingStartThumb = false
        isTouchingEndThumb = false
        startThumbView.backgroundColor = .white
        endThumbView.backgroundColor = .white
        topBoundaryLayer.backgroundColor = UIColor.white.cgColor
        bottomBoundaryLayer.backgroundColor = UIColor.white.cgColor

        debugPrint("startValue: \(startValue)")
        debugPrint("endValue: \(endValue)")
    }
}
