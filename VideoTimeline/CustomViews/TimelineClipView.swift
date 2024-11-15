//
//  TimelineClipView.swift
//  VideoTimeline
//
//  Created by Aamir on 05/11/2024.
//

import Foundation
import UIKit

final class TimelineClipView: UIView {
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 1
    
    private let overlayView = UIView()
    private var collectionView: UICollectionView!
    private var trimmingHandle: TrimmingHandleView!

    private let itemWidth: CGFloat = 40
    private let itemHeight: CGFloat = 80
    private var numberOfItems = 5
    private var lastItemChangeTime: TimeInterval = 0
    private var accumulatedScaleChange: Double = 0.0
    
    // Color based on index
    let colorPattern: [UIColor] = [
        .red, .blue, .green, .yellow, .purple, .brown, .cyan, .magenta, .orange, .darkGray
    ]

    // Indicating center of clip view
    private let centerIndicatorLine: UIView = {
        let line = UIView()
        line.backgroundColor = .white
        line.layer.cornerRadius = 4
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()

    init() {
        super.init(frame: .zero)
        trimmingHandle = TrimmingHandleView(viewModel: TrimmingHandlerViewModel())
        trimmingHandle.delegate = self
        setupOverlayView()
        setupView()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trimmingHandle.updateFrames()
        addBorderToCollectionView()
    }

    // Update frame and border when content size changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            trimmingHandle.updateFrames()
            addBorderToCollectionView()
        }
    }
}

// MARK: Setup UI
private extension TimelineClipView {
    func setupView() {
        layer.cornerRadius = 8

        // Set up the collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
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

        // Center align clip view initially
        let centerInset = UIScreen.main.bounds.width / 2 - layout.itemSize.width / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: centerInset, bottom: 0, right: centerInset)
        collectionView.contentOffset = CGPoint(x: -(numberOfItems * 35)/2, y: 0)

        addSubview(collectionView)
        bringSubviewToFront(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: itemHeight)
        ])
        collectionView.layoutIfNeeded()
        collectionView.addSubview(trimmingHandle)
        trimmingHandle.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: itemHeight)
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

        trimmingHandle.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: itemHeight)
        collectionView.bringSubviewToFront(trimmingHandle)
        collectionView.bringSubviewToFront(trimmingHandle.endThumbView)
        trimmingHandle.topBoundaryLayer.zPosition = 1
        trimmingHandle.bottomBoundaryLayer.zPosition = 1
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

    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGesture)
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

// MARK: - UICollectionView DataSource and Delegate
extension TimelineClipView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineClipCollectionViewCell.identifier, for: indexPath) as! TimelineClipCollectionViewCell
        cell.backgroundColor = colorPattern[indexPath.item % colorPattern.count]
        cell.configure(with: indexPath.item + 1)
        return cell
    }
}

// MARK: Gesture Handlers
private extension TimelineClipView {
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        var initialScale: CGFloat = 1.0
        switch sender.state {
        case .began:
            initialScale = sender.scale
            accumulatedScaleChange = 0.0

        case .changed:
            let scaleDelta = sender.scale - initialScale
            accumulatedScaleChange += scaleDelta

            // Only add or remove items when accumulated change surpasses threshold and debounce with time delay
            let scaleThreshold: CGFloat = 0.2
            let debounceDelay: TimeInterval = 0.2

            let currentTime = Date().timeIntervalSince1970
            if abs(accumulatedScaleChange) > scaleThreshold, currentTime - lastItemChangeTime > debounceDelay {
                let shouldAddItem = accumulatedScaleChange > 0
                let currentItemCount = collectionView.numberOfItems(inSection: 0)

                UIView.animate(withDuration: 0.2) { [unowned self] in
                    collectionView.performBatchUpdates({
                        if shouldAddItem && currentItemCount < Int(itemWidth) {
                            collectionView.insertItems(at: [IndexPath(item: currentItemCount, section: 0)])
                            numberOfItems = currentItemCount + 1
                            UIView.animate(withDuration: 0.1) {
                                self.collectionView.contentOffset.x += self.itemWidth / 2
                            }
                        } else if !shouldAddItem && currentItemCount > 5 {
                            collectionView.deleteItems(at: [IndexPath(item: currentItemCount - 1, section: 0)])
                            numberOfItems = currentItemCount - 1
                            UIView.animate(withDuration: 0.1) {
                                self.collectionView.contentOffset.x -= self.itemWidth / 2
                            }
                        }
                    }, completion: nil)
                }

                accumulatedScaleChange = 0.0
                lastItemChangeTime = currentTime
            }
        case .ended:
            collectionView.reloadData()
        default:
            break
        }
    }
}

extension TimelineClipView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(x: collectionView.bounds.midX, y: 0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint),
           let centerCell = collectionView.cellForItem(at: indexPath) {
            overlayView.backgroundColor = centerCell.backgroundColor
        }
    }
}

extension TimelineClipView: TrimmingHandleViewDelegate {
    func positionForValue(_ value: CGFloat) -> CGFloat {
        collectionView.contentSize.width * (value - minimumValue) / (maximumValue - minimumValue)
    }

    func valueForPosition(_ position: CGFloat) -> CGFloat {
        minimumValue + (maximumValue - minimumValue) * position / collectionView.contentSize.width
    }
    
    func updateLayout(_ startValue: CGFloat, _ endValue: CGFloat) {
        let start = positionForValue(startValue)
        let end = positionForValue(endValue)
        frame.origin.x = start
        frame.size.width = end - start
    }
    
    func centerContentOffset() {
        let collectionViewWidth = collectionView.bounds.width
        let contentWidth = CGFloat(numberOfItems) * itemWidth
        let targetOffsetX = (collectionViewWidth - contentWidth ) / 2

        if contentWidth < collectionViewWidth {
            UIView.animate(withDuration: 0.2) {
                self.collectionView.contentOffset.x = -targetOffsetX
            }
        }
    }
    
    // Remove items from collection on trimming
    func updateCollectionViewForPositionChange(_ position: CGFloat) {
        let currentItemCount = collectionView.numberOfItems(inSection: 0)
        
        let itemsDelta = position / itemWidth
        let roundedDelta = round(itemsDelta)
        
        // Check if position change surpasses threshold to add or remove items
        if abs(roundedDelta) >= 1 {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.collectionView.performBatchUpdates({
                    if roundedDelta < 0 {
                        let newItemCount = currentItemCount + Int(roundedDelta)
                        guard newItemCount > 2 else { return }
                        let indexPathsToRemove = (newItemCount..<currentItemCount).map { IndexPath(item: $0, section: 0) }
                        collectionView.deleteItems(at: indexPathsToRemove)
                        numberOfItems = newItemCount
                    } else {
                        let newItemCount = currentItemCount - Int(roundedDelta)
                        guard newItemCount > 2 else { return }
                        let indexPathsToRemove = (0..<currentItemCount-newItemCount).map { IndexPath(item: $0, section: 0) }
                        collectionView.deleteItems(at: indexPathsToRemove)
                        numberOfItems = newItemCount
                    }
                }, completion: nil)
            }
            collectionView.reloadData()
        }
    }
}
