//
//  TimelineView.swift
//  VideoTimeline
//
//  Created by Aamir on 05/11/2024.
//

import Foundation
import UIKit

final class TimelineView: UIView {
    private let trimmingHandlerView = TrimmingHandlerView(viewModel: TrimmingHandlerViewModel())
    private let previewStackView = UIStackView()
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
    
    private var viewModel: TimelineViewModel
    
    init(viewModel: TimelineViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupOverlayView()
        setupTrimmingHandlerView()
        setupPageNumberLabel()
        setupGestures()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // This is not required in your case
    }
}

// MARK: Binding
private extension TimelineView {
    func bindViewModel() {
        viewModel.updateScale = { [weak self] in
            let transform = CGAffineTransform(scaleX: self?.viewModel.currentScale ?? 1.0, y: self?.viewModel.currentScale ?? 1.0)
            self?.overlayView.transform = transform
            self?.pageNumberLabel.transform = transform
        }
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
            viewModel.handlePinchGesture(scale: sender.scale, currentScale)
            sender.scale = 1.0
        }
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        debugPrint("TimelineView tapped!")
    }
}
