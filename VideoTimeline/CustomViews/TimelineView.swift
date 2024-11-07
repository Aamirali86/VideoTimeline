//
//  TimelineView.swift
//  VideoTimeline
//
//  Created by Aamir on 05/11/2024.
//

import Foundation
import UIKit

final class TimelineView: UIView {
    private let trimmingHandlerView = TrimmingHandlerView()
    private let previewStackView = UIStackView()
    // added overlay that will handle all the gestures
    private let overlayView = UIView()
    
    let pageNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupOverlayView()
        setupTrimmingHandlerView()
        setupPageNumberLabel()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupOverlayView()
        setupTrimmingHandlerView()
        setupPageNumberLabel()
        setupGestures()
    }
}

// MARK: Setup UI
private extension TimelineView {
    func setupView() {
        layer.cornerRadius = 8

        previewStackView.axis = .horizontal
        previewStackView.distribution = .fillEqually
        previewStackView.spacing = 0

        addSubview(previewStackView)

        previewStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            previewStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            previewStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            previewStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addPreviewBoxes()
    }
    
    func setupTrimmingHandlerView() {
        previewStackView.addSubview(trimmingHandlerView)
        bringSubviewToFront(previewStackView)
        
        trimmingHandlerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trimmingHandlerView.leadingAnchor.constraint(equalTo: previewStackView.leadingAnchor),
            trimmingHandlerView.trailingAnchor.constraint(equalTo: previewStackView.trailingAnchor),
            trimmingHandlerView.topAnchor.constraint(equalTo: previewStackView.topAnchor),
            trimmingHandlerView.bottomAnchor.constraint(equalTo: previewStackView.bottomAnchor)
        ])
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
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupPageNumberLabel() {
        addSubview(pageNumberLabel)
        
        NSLayoutConstraint.activate([
            pageNumberLabel.widthAnchor.constraint(equalToConstant: 160),
            pageNumberLabel.heightAnchor.constraint(equalToConstant: 60),
            pageNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        overlayView.addGestureRecognizer(pinchGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        overlayView.addGestureRecognizer(tapGesture)
    }

    func addPreviewBoxes() {
        for i in 0..<15 { // Add 15 preview boxes
            let previewBox = UIView()
            previewBox.backgroundColor = i == 0 || i == 14 ? .clear : randomColor()
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
            let currentScale = overlayView.frame.size.width / overlayView.bounds.size.width
            var newScale = sender.scale * currentScale
            
            // Prevent zooming out below the original size
            if newScale < 1.0 {
                newScale = 1.0
            }
            
            // Prevent zooming beyond a maximum scale
            let maxScale: CGFloat = 1.5
            if newScale > maxScale {
                newScale = maxScale
            }
            
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            overlayView.transform = transform
            pageNumberLabel.transform = transform
            sender.scale = 1.0
        }
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        debugPrint("TimelineView tapped!")
    }
}
