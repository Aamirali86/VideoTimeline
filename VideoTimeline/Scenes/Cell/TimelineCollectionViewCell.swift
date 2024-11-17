//
//  TimelineCollectionViewCell.swift
//  VideoTimeline
//
//  Created by Aamir on 16/11/2024.
//

import UIKit

protocol TimelineCollectionViewCellDelegate: AnyObject {
    func didUpdateTrimming(for cell: TimelineCollectionViewCell, currentWidth: CGFloat)
    func reloadView()
}

final class TimelineCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimelineClipCollectionViewCell"
    weak var delegate: TimelineCollectionViewCellDelegate?
    
    private let topBorder = CALayer()
    private let bottomBorder = CALayer()
    private let leftHandle = UIView()
    private let rightHandle = UIView()

    private let startPanGesture = UIPanGestureRecognizer()
    private let endPanGesture = UIPanGestureRecognizer()
    
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 1
    
    // Maintaining the state of trimming handlers
    private var initialStartThumbX: CGFloat = 0
    private var initialEndThumbX: CGFloat = 0
    
    private(set) var startValue: CGFloat = 0 {
        didSet {
            startValue = min(startValue, endValue - minimumTrimLength)
        }
    }
    
    private(set) var endValue: CGFloat = 1 {
        didSet {
            endValue = max(startValue + minimumTrimLength, endValue)
        }
    }
    
    // Minimum distance between handlers to avoid intersaction
    let minimumTrimLength: CGFloat = 0.2

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    var isSelectedForTrimming: Bool = false {
        didSet {
            topBorder.backgroundColor = isSelectedForTrimming ? UIColor.white.cgColor : UIColor.clear.cgColor
            bottomBorder.backgroundColor = isSelectedForTrimming ? UIColor.white.cgColor : UIColor.clear.cgColor
            leftHandle.backgroundColor = isSelectedForTrimming ? UIColor.white : UIColor.clear
            rightHandle.backgroundColor = isSelectedForTrimming ? UIColor.white : UIColor.clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        setupBorders()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    func configure(with clip: TimelineClip) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var clip = clip
        let visibleBoxes = clip.visibleColorBoxes(for: bounds.width)
        
        for (index, color) in visibleBoxes.enumerated() {
            let containerView = UIView()
            containerView.backgroundColor = color
            containerView.frame = CGRect(origin: .zero, size: clip.size)
            
            let label = UILabel()
            label.text = "\(index)"
            label.textColor = .white
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.textAlignment = .center
            containerView.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])

            stackView.addArrangedSubview(containerView)
        }
    }
}

// MARK: - Setup UI
private extension TimelineCollectionViewCell {
    func updateFrames() {
        let startThumb = positionForValue(startValue)
        let endThumb = positionForValue(endValue)
        
        let borderWidthHorizontal: CGFloat = 20
        let borderWidthVertical: CGFloat = 4

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        leftHandle.frame = CGRect(x: startThumb, y: 0, width: borderWidthHorizontal, height: contentView.bounds.height)
        rightHandle.frame = CGRect(x: endThumb - borderWidthHorizontal, y: 0, width: borderWidthHorizontal, height: contentView.bounds.height)
        
        let boundaryWidth = endThumb - startThumb
        topBorder.frame = CGRect(x: startThumb, y: 0, width: boundaryWidth, height: borderWidthVertical)
        bottomBorder.frame = CGRect(x: startThumb, y: contentView.bounds.height - borderWidthVertical, width: boundaryWidth, height: borderWidthVertical)
        
        CATransaction.commit()
    }
    
    func updateStartValue(to value: CGFloat) {
        startValue = value
    }

    func updateEndValue(to value: CGFloat) {
        endValue = value
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        bounds.width * (value - minimumValue) / (maximumValue - minimumValue)
    }

    func valueForPosition(_ position: CGFloat) -> CGFloat {
        minimumValue + (maximumValue - minimumValue) * position / bounds.width
    }
    
    func updateLayout() {
        let start = positionForValue(startValue)
        let end = positionForValue(endValue)
        frame.origin.x = start
        frame.size.width = end - start
    }
    
    func setupBorders() {
        contentView.layer.addSublayer(topBorder)
        contentView.layer.addSublayer(bottomBorder)
        contentView.addSubview(rightHandle)
        contentView.addSubview(leftHandle)
    }
    
    private func setupGestures() {
        startPanGesture.addTarget(self, action: #selector(handleStartPan(_:)))
        endPanGesture.addTarget(self, action: #selector(handleEndPan(_:)))
        
        leftHandle.addGestureRecognizer(startPanGesture)
        rightHandle.addGestureRecognizer(endPanGesture)
    }
}

// MARK: - Gestures
private extension TimelineCollectionViewCell {
    @objc func handleStartPan(_ gesture: UIPanGestureRecognizer) {
        guard isSelectedForTrimming else { return }
        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: contentView)
        switch gesture.state {
        case .began:
            initialStartThumbX = leftHandle.frame.origin.x
        case .changed:
            let newValue = valueForPosition(initialStartThumbX + translation.x)
            updateStartValue(to: min(newValue, endValue - minimumTrimLength))
            updateLayout()
            delegate?.didUpdateTrimming(for: self, currentWidth: frame.size.width)
        case .ended:
            delegate?.reloadView()
        default:
            break
        }
    }

    @objc func handleEndPan(_ gesture: UIPanGestureRecognizer) {
        guard isSelectedForTrimming else { return }
        
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            initialEndThumbX = rightHandle.frame.origin.x
        case .changed:
            let newValue = valueForPosition(initialEndThumbX + translation.x)
            updateEndValue(to: max(newValue, startValue + minimumTrimLength))
            updateLayout()
            delegate?.didUpdateTrimming(for: self, currentWidth: frame.size.width)
        case .ended:
            delegate?.reloadView()
        default:
            break
        }
    }
}
