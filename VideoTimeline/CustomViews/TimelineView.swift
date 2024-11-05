//
//  TimelineView.swift
//  VideoTimeline
//
//  Created by Aamir on 05/11/2024.
//

import Foundation
import UIKit

final class TimelineView: UIView {
    private let previewScrollView = UIScrollView()
    private let previewStackView = UIStackView()
    // added overlay that will handle all the gestures
    private let overlayView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupOverlayView()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupOverlayView()
        setupGestures()
    }
}

// MARK: Setup UI
private extension TimelineView {
    func setupView() {
        backgroundColor = .lightGray
        layer.cornerRadius = 8

        previewScrollView.showsHorizontalScrollIndicator = false
        previewStackView.axis = .horizontal
        previewStackView.distribution = .fillEqually
        previewStackView.spacing = 0

        addSubview(previewScrollView)
        previewScrollView.addSubview(previewStackView)

        previewScrollView.translatesAutoresizingMaskIntoConstraints = false
        previewStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewScrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            previewScrollView.heightAnchor.constraint(equalToConstant: 60),

            previewStackView.leadingAnchor.constraint(equalTo: previewScrollView.leadingAnchor),
            previewStackView.trailingAnchor.constraint(equalTo: previewScrollView.trailingAnchor),
            previewStackView.topAnchor.constraint(equalTo: previewScrollView.topAnchor),
            previewStackView.bottomAnchor.constraint(equalTo: previewScrollView.bottomAnchor),
            previewStackView.heightAnchor.constraint(equalTo: previewScrollView.heightAnchor)
        ])

        addPreviewBoxes()
    }
    
    func setupOverlayView() {
        overlayView.backgroundColor = randomColor()
        overlayView.layer.cornerRadius = 5
        addSubview(overlayView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80)
        ])
    }

    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        overlayView.addGestureRecognizer(pinchGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        overlayView.addGestureRecognizer(tapGesture)
    }

    func addPreviewBoxes() {
        for _ in 0..<20 { // Add 20 preview boxes
            let previewBox = UIView()
            previewBox.backgroundColor = randomColor()
            previewBox.layer.cornerRadius = 0
            previewBox.clipsToBounds = true
            previewStackView.addArrangedSubview(previewBox)

            // Set width for each preview box
            previewBox.translatesAutoresizingMaskIntoConstraints = false
            previewBox.widthAnchor.constraint(equalToConstant: 30).isActive = true
        }
    }

    func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}

// MARK: Gesture Handlers
private extension TimelineView {
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            let currentScale = self.frame.size.width / self.bounds.size.width
            var newScale = sender.scale * currentScale
            
            // Prevent zooming out below the original size
            if newScale < 1.0 {
                newScale = 1.0
            }
            
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            self.transform = transform
            sender.scale = 1.0
        }
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        debugPrint("TimelineView tapped!")
    }
}
