//
//  ViewController.swift
//  VideoTimeline
//
//  Created by Aamir on 04/11/2024.
//

import UIKit

final class VideoTimelineController: UIViewController {
    private let pagerController = VideoTimelinePagerController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var collectionView: TimelineCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPagerController()
        addCollectionView()
    }
}

// MARK: UI setup
private extension VideoTimelineController {
    func addPagerController() {
        addChild(pagerController)
        view.addSubview(pagerController.view)
        pagerController.didMove(toParent: self)
        
        pagerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagerController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func addCollectionView() {
        collectionView = TimelineCollectionView()
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
