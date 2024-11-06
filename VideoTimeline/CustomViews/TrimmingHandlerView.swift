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

    // Handler gestures
    private let startThumbPanGesture = UIPanGestureRecognizer()
    private let endThumbPanGesture = UIPanGestureRecognizer()

    // Maintaining the state of trimming handlers
    private var initialStartThumbX: CGFloat = 0
    private var initialEndThumbX: CGFloat = 0

    // Trimming view border layers
    private let topBorderLayer = CALayer()
    private let bottomBorderLayer = CALayer()
    private let leftBorderLayer = CALayer()
    private let rightBorderLayer = CALayer()
    
    // Added white/yellow boundry over trimming view
    private let topBoundaryLayer = CALayer()
    private let bottomBoundaryLayer = CALayer()
    private let startThumbView = UIView()
    private let endThumbView = UIView()
    
    private let handleWidth: CGFloat = 20.0
    private let handleHeight: CGFloat = 68.0
    
    // Minimum distance between handlers to avoid intersaction
    private let minimumTrimLength: CGFloat = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupGestures()
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
        
        topBorderLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(topBorderLayer)
        
        bottomBorderLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(bottomBorderLayer)
        
        leftBorderLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(leftBorderLayer)
        
        rightBorderLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(rightBorderLayer)
        
        updateFrames()
        addImage(handle: startThumbView, leading: true)
        addImage(handle: endThumbView, leading: false)
    }
    
    func setupGestures() {
        startThumbPanGesture.addTarget(self, action: #selector(handleStartThumbPan(_:)))
        endThumbPanGesture.addTarget(self, action: #selector(handleEndThumbPan(_:)))
        
        startThumbView.addGestureRecognizer(startThumbPanGesture)
        endThumbView.addGestureRecognizer(endThumbPanGesture)
        
        // To prioritize trimming gestures, make sure they don't conflict with pager gestures
        if let pagerGesture = superview?.gestureRecognizers?.first {
            startThumbPanGesture.require(toFail: pagerGesture)
            endThumbPanGesture.require(toFail: pagerGesture)
        }
    }
    
    func updateHighlighting(for state: UIGestureRecognizer.State) {
        let color: UIColor = (state == .began || state == .changed) ? .yellow : .white
        startThumbView.backgroundColor = color
        endThumbView.backgroundColor = color
        topBoundaryLayer.backgroundColor = color.cgColor
        bottomBoundaryLayer.backgroundColor = color.cgColor
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
        let maxWidth = positionForValue(1)
        
        // Disable implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        startThumbView.frame = CGRect(x: startThumb, y: -4, width: handleWidth, height: handleHeight)
        endThumbView.frame = CGRect(x: endThumb - handleWidth, y: -4, width: handleWidth, height: handleHeight)
        
        let boundaryWidth = endThumb - startThumb
        topBoundaryLayer.frame = CGRect(x: startThumb, y: -4, width: boundaryWidth, height: 4)
        bottomBoundaryLayer.frame = CGRect(x: startThumb, y: bounds.height, width: boundaryWidth, height: 4)
        
        CATransaction.commit()
        
        topBorderLayer.frame = CGRect(x: handleWidth, y: -2, width: maxWidth - (handleWidth * 2), height: 2)
        bottomBorderLayer.frame = CGRect(x: handleWidth, y: bounds.height, width: maxWidth - (handleWidth * 2), height: 2)
        leftBorderLayer.frame = CGRect(x: handleWidth, y: 0, width: 2, height: 60)
        rightBorderLayer.frame = CGRect(x: maxWidth - handleWidth, y: -2, width: 2, height: 64)
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
    @objc func handleStartThumbPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            initialStartThumbX = startThumbView.frame.origin.x
        case .changed:
            let newValue = valueForPosition(initialStartThumbX + translation.x)
            startValue = max(0, min(newValue, endValue - minimumTrimLength))
            updateHighlighting(for: .changed)
        case .ended, .cancelled:
            updateHighlighting(for: .ended)
        default:
            break
        }
    }

    @objc func handleEndThumbPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            initialEndThumbX = endThumbView.frame.origin.x + handleWidth
        case .changed:
            let newValue = valueForPosition(initialEndThumbX + translation.x)
            endValue = min(1, max(newValue, startValue + minimumTrimLength))
            updateHighlighting(for: .changed)
        case .ended, .cancelled:
            updateHighlighting(for: .ended)
        default:
            break
        }
    }
}
