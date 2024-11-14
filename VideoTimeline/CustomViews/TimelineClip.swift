//
//  TimelineView.swift
//  VideoTimeline
//
//  Created by Aamir on 05/11/2024.
//

import Foundation
import UIKit

final class TimelineClip: UIView {
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 1
    
    private let overlayView = UIView()
    private var collectionView: UICollectionView!
    private let leftHandle = UIView()
    private let rightHandle = UIView()
    
    // Minimum distance between handlers to avoid intersaction
    let minimumTrimLength: CGFloat = 0.2
    
    private let handleWidth: CGFloat = 10.0
    private let handleHeight: CGFloat = 70.0
    private var numberOfItems = 5
    private var lastItemChangeTime: TimeInterval = 0
    private var accumulatedScaleChange: Double = 0.0
    
    let colorPattern: [UIColor] = [
        .red, .blue, .green, .yellow, .purple, .brown, .cyan, .magenta, .orange, .darkGray
    ]

    // Maintaining the state of trimming handlers
    private var initialStartThumbX: CGFloat = 0
    private var initialEndThumbX: CGFloat = 0
    private var initialScale: CGFloat = 1.0
    
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
    
    private let centerIndicatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = .white
        line.layer.cornerRadius = 4
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()

    private var viewModel: TimelineViewModel
    
    init(viewModel: TimelineViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupOverlayView()
        setupView()
        setupPageNumberLabel()
        setupGestures()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
        addBorderToCollectionView()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            addBorderToCollectionView()
            updateFrames()
        }
    }
}

// MARK: Binding
private extension TimelineClip {
    func bindViewModel() {
        viewModel.updateScale = { [weak self] in
            let transform = CGAffineTransform(scaleX: self?.viewModel.currentScale ?? 1.0, y: self?.viewModel.currentScale ?? 1.0)
            self?.overlayView.transform = transform
            self?.pageNumberLabel.transform = transform
        }
    }
}

// MARK: Setup UI
private extension TimelineClip {
    func setupView() {
        layer.cornerRadius = 8

        // Set up the collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 30, height: 60)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        // Initialize the collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TimelineClipCollectionViewCell.self, forCellWithReuseIdentifier: TimelineClipCollectionViewCell.identifier)
        collectionView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        
        let centerOffset = UIScreen.main.bounds.width / 2 - layout.itemSize.width / 2 - 12
        collectionView.contentInset = UIEdgeInsets(top: 0, left: centerOffset, bottom: 0, right: centerOffset)
        collectionView.contentOffset = CGPoint(x: -((numberOfItems * 30)/2 + 30), y: 0)

        addSubview(collectionView)
        bringSubviewToFront(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        setupHandles()
        setupCenterIndicatorLine()
    }
    
    func addBorderToCollectionView() {
        collectionView.layer.sublayers?
            .filter { $0.name == "contentBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let borderLayer = CALayer()
        borderLayer.name = "contentBorderLayer"
        borderLayer.borderColor = UIColor.black.cgColor
        borderLayer.borderWidth = 2
        borderLayer.frame = CGRect(x: 0, y: 0, width: collectionView.contentSize.width, height: collectionView.bounds.height)
        collectionView.layer.addSublayer(borderLayer)
        
        collectionView.bringSubviewToFront(leftHandle)
        collectionView.bringSubviewToFront(rightHandle)
    }
    
    func setupHandles() {
        collectionView.layoutIfNeeded()
        
        leftHandle.backgroundColor = .white
        leftHandle.layer.cornerRadius = 4
        collectionView.addSubview(leftHandle)
        
        rightHandle.backgroundColor = .white
        rightHandle.layer.cornerRadius = 4
        collectionView.addSubview(rightHandle)

        leftHandle.isUserInteractionEnabled = true
        rightHandle.isUserInteractionEnabled = true
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
    
    func setupCenterIndicatorLine() {
        addSubview(centerIndicatorLine)
        
        NSLayoutConstraint.activate([
            centerIndicatorLine.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            centerIndicatorLine.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            
            centerIndicatorLine.widthAnchor.constraint(equalToConstant: 4),
            centerIndicatorLine.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 1.5)
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
        collectionView.addGestureRecognizer(pinchGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        let startThumbPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStartThumbPan(_:)))
        let endThumbPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleEndThumbPan(_:)))
        leftHandle.addGestureRecognizer(startThumbPanGesture)
        rightHandle.addGestureRecognizer(endThumbPanGesture)
        
        // To prioritize trimming gestures, make sure they don't conflict with pager gestures
        if let pagerGesture = superview?.gestureRecognizers?.first {
            startThumbPanGesture.require(toFail: pagerGesture)
            endThumbPanGesture.require(toFail: pagerGesture)
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
    
    func updateStartValue(to value: CGFloat) {
        startValue = value
    }

    func updateEndValue(to value: CGFloat) {
        endValue = value
    }
    
    func updateFrames() {
        let startThumb = positionForValue(startValue)
        let endThumb = positionForValue(endValue)
        leftHandle.frame = CGRect(x: startThumb + 3, y: -5, width: handleWidth, height: handleHeight)
        rightHandle.frame = CGRect(x: endThumb - handleWidth - 3, y: -5, width: handleWidth, height: handleHeight)
    }
    
    func updateLayout() {
        let start = positionForValue(startValue)
        let end = positionForValue(endValue)
        frame.origin.x = start
        frame.size.width = end - start
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        collectionView.contentSize.width * (value - minimumValue) / (maximumValue - minimumValue)
    }

    func valueForPosition(_ position: CGFloat) -> CGFloat {
        minimumValue + (maximumValue - minimumValue) * position / collectionView.contentSize.width
    }
    
    func updateHighlighting(for state: UIGestureRecognizer.State) {
        let color: UIColor = (state == .began || state == .changed) ? .yellow : .white
        leftHandle.backgroundColor = color
        rightHandle.backgroundColor = color
    }
}

// MARK: - UICollectionView DataSource and Delegate
extension TimelineClip: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineClipCollectionViewCell.identifier, for: indexPath) as! TimelineClipCollectionViewCell
        cell.backgroundColor = colorPattern[indexPath.item % colorPattern.count]
        return cell
    }
}

// MARK: Gesture Handlers
private extension TimelineClip {
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            initialScale = sender.scale
            accumulatedScaleChange = 0.0

        case .changed:
            let scaleDelta = sender.scale - initialScale
            accumulatedScaleChange += scaleDelta
            initialScale = sender.scale

            // Only add or remove items when accumulated change surpasses threshold and debounce with time delay
            let scaleThreshold: CGFloat = 0.3
            let debounceDelay: TimeInterval = 0.2

            let currentTime = Date().timeIntervalSince1970
            if abs(accumulatedScaleChange) > scaleThreshold, currentTime - lastItemChangeTime > debounceDelay {
                let shouldAddItem = accumulatedScaleChange > 0
                let currentItemCount = collectionView.numberOfItems(inSection: 0)

                collectionView.performBatchUpdates({
                    if shouldAddItem && currentItemCount < 40 {
                        collectionView.insertItems(at: [IndexPath(item: currentItemCount, section: 0)])
                        numberOfItems = currentItemCount + 1
                        UIView.animate(withDuration: 0.1) {
                            self.collectionView.contentOffset.x += 30 / 2
                        }
                    } else if !shouldAddItem && currentItemCount > 5 {
                        collectionView.deleteItems(at: [IndexPath(item: currentItemCount - 1, section: 0)])
                        numberOfItems = currentItemCount - 1
                        UIView.animate(withDuration: 0.1) {
                            self.collectionView.contentOffset.x -= 30 / 2
                        }
                    }
                }, completion: nil)

                accumulatedScaleChange = 0.0
                lastItemChangeTime = currentTime
            }
        case .ended:
            collectionView.reloadData()
        default:
            break
        }
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        debugPrint("TimelineView tapped!")
    }
}

// MARK: Gesture handler
extension TimelineClip {
    @objc func handleStartThumbPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            initialStartThumbX = leftHandle.frame.origin.x
        case .changed:
            let newValue = valueForPosition(initialStartThumbX + translation.x)
            updateStartValue(to: max(0, min(newValue, endValue - minimumTrimLength)))
            updateLayout()
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
            initialEndThumbX = rightHandle.frame.origin.x + handleWidth
        case .changed:
            let newValue = valueForPosition(initialEndThumbX + translation.x)
            updateEndValue(to: min(1, max(newValue, startValue + minimumTrimLength)))
            updateLayout()
            updateHighlighting(for: .changed)
        case .ended, .cancelled:
            updateHighlighting(for: .ended)
        default:
            break
        }
    }
}

extension TimelineClip: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(x: collectionView.bounds.midX, y: 0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint),
           let centerCell = collectionView.cellForItem(at: indexPath) {
            overlayView.backgroundColor = centerCell.backgroundColor
        }
    }
}
