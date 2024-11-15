//
//  TrimmingHandlerView.swift
//  VideoTimeline
//
//  Created by Aamir on 06/11/2024.
//

import Foundation
import UIKit

protocol TrimmingHandleViewDelegate: AnyObject {
    func positionForValue(_ value: CGFloat) -> CGFloat
    func valueForPosition(_ value: CGFloat) -> CGFloat
    func updateLayout(_ startValue: CGFloat, _ endValue: CGFloat)
    func centerContentOffset()
    func updateCollectionViewForPositionChange(_ position: CGFloat)
}

final class TrimmingHandleView: UIView {
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 1
    
    private var viewModel: TrimmingHandlerViewModel
    weak var delegate: TrimmingHandleViewDelegate?

    // Handler gestures
    private let startThumbPanGesture = UIPanGestureRecognizer()
    private let endThumbPanGesture = UIPanGestureRecognizer()

    // Maintaining the state of trimming handlers
    private var initialStartThumbX: CGFloat = 0
    private var initialEndThumbX: CGFloat = 0

    let startThumbView = UIView()
    let endThumbView = UIView()
    let topBoundaryLayer = CALayer()
    let bottomBoundaryLayer = CALayer()

    private let handleWidth: CGFloat = 15.0
    private let handleHeight: CGFloat = 80.0
    
    init(viewModel: TrimmingHandlerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupLayers()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFrames() {
        guard let startThumb = delegate?.positionForValue(viewModel.startValue),
            let endThumb = delegate?.positionForValue(viewModel.endValue) else {
            return
        }
        
        // Disable implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Updating trim frame once dragged
        startThumbView.frame = CGRect(x: startThumb, y: 0, width: handleWidth, height: handleHeight)
        endThumbView.frame = CGRect(x: endThumb - handleWidth, y: 0, width: handleWidth, height: handleHeight)
        
        let boundaryWidth = endThumb - startThumb
        topBoundaryLayer.frame = CGRect(x: startThumb, y: -2, width: boundaryWidth, height: 4)
        bottomBoundaryLayer.frame = CGRect(x: startThumb, y: handleHeight - 2, width: boundaryWidth, height: 4)
        
        CATransaction.commit()
    }
}

// MARK: UI Setup
private extension TrimmingHandleView {
    func setupLayers() {
        topBoundaryLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(topBoundaryLayer)
        
        bottomBoundaryLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(bottomBoundaryLayer)
        
        startThumbView.backgroundColor = UIColor.white
        startThumbView.isUserInteractionEnabled = true
        addSubview(startThumbView)
        
        endThumbView.backgroundColor = UIColor.white
        endThumbView.isUserInteractionEnabled = true
        addSubview(endThumbView)
        
        updateFrames()
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
    
    func updateLayout() {
        delegate?.updateLayout(viewModel.startValue, viewModel.endValue)
    }
}

// MARK: Gesture handler
extension TrimmingHandleView {
    @objc func handleStartThumbPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            initialStartThumbX = startThumbView.frame.origin.x
        case .changed:
            guard let newValue = delegate?.valueForPosition(initialStartThumbX + translation.x) else { return }
            viewModel.updateStartValue(to: max(0, min(newValue, viewModel.endValue - viewModel.minimumTrimLength)))
            updateLayout()
            updateHighlighting(for: .changed)
        case .ended, .cancelled:
            let finalPosition = startThumbView.frame.origin.x
            let positionChange = finalPosition - initialStartThumbX
            delegate?.updateCollectionViewForPositionChange(positionChange)
            updateHighlighting(for: .ended)
            viewModel.updateStartValue(to: 0)
            delegate?.centerContentOffset()
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
            guard let newValue = delegate?.valueForPosition(initialEndThumbX + translation.x) else { return }
            viewModel.updateEndValue(to: min(1, max(newValue, viewModel.startValue + viewModel.minimumTrimLength)))
            updateLayout()
            updateHighlighting(for: .changed)
        case .ended, .cancelled:
            let finalPosition = endThumbView.frame.origin.x
            let positionChange = finalPosition - initialEndThumbX
            delegate?.updateCollectionViewForPositionChange(positionChange)
            updateHighlighting(for: .ended)
            viewModel.updateEndValue(to: 1)
            delegate?.centerContentOffset()
        default:
            break
        }
    }
}
