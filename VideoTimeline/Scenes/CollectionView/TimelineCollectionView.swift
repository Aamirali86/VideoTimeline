//
//  TimelineCollectionView.swift
//  VideoTimeline
//
//  Created by Aamir on 16/11/2024.
//

import UIKit

final class TimelineCollectionView: UIView {
    private var clips: [TimelineClip] = []
    private var selectedIndexPath: IndexPath?
    
    private let collectionView: UICollectionView = {
        let layout = TimelineCustomLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    init() {
        self.clips = [
            TimelineClip(size: .init(width: 40, height: 80), colorBoxes: [.red, .green, .blue, .yellow, .purple]),
            TimelineClip(size: .init(width: 40, height: 80), colorBoxes: [.red, .green, .blue, .yellow, .purple]),
            TimelineClip(size: .init(width: 40, height: 80), colorBoxes: [.red, .green, .blue, .yellow, .purple]),
            TimelineClip(size: .init(width: 40, height: 80), colorBoxes: [.red, .green, .blue, .yellow, .purple])
        ]

        super.init(frame: .zero)
        setupCollectionView()
        setupGestures()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideCell(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Collection view
extension TimelineCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .lightGray
        collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimelineCollectionViewCell.self, forCellWithReuseIdentifier: TimelineCollectionViewCell.identifier)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        clips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineCollectionViewCell.identifier, for: indexPath) as? TimelineCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.isSelectedForTrimming = indexPath == selectedIndexPath
        cell.configure(with: clips[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPath = nil
        collectionView.reloadData()
    }
}

// MARK: - Delegate
extension TimelineCollectionView: TimelineCollectionViewCellDelegate {
    func didUpdateTrimming(for cell: TimelineCollectionViewCell, currentWidth: CGFloat) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let layout = collectionView.collectionViewLayout as? TimelineCustomLayout else { return }
        layout.updateItemWidth(for: indexPath, currentWidth)
    }
    
    func reloadView() {
        collectionView.reloadData()
    }
}

// MARK: Gesture Handlers
private extension TimelineCollectionView {
    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handleTapOutsideCell(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        
        if collectionView.indexPathForItem(at: location) == nil {
            selectedIndexPath = nil
            collectionView.reloadData()
        }
    }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let layout = collectionView.collectionViewLayout as? TimelineCustomLayout else { return }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        if sender.state == .changed {
            for indexPath in visibleIndexPaths {
                let currentWidth = layout.defaultItemWidth
                let newWidth = currentWidth * sender.scale
                
                layout.updateItemWidth(for: indexPath, newWidth)
                _ = clips[indexPath.item].visibleColorBoxes(for: newWidth)
            }
        }
        if sender.state == .ended {
            collectionView.reloadData()
            sender.scale = 1.0
        }
    }
}
