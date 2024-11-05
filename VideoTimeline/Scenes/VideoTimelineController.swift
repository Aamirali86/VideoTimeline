//
//  ViewController.swift
//  VideoTimeline
//
//  Created by Aamir on 04/11/2024.
//

import UIKit

final class VideoTimelineController: UIViewController {
    var viewModel: VideoTimelineViewModel!
    private let timelineView = TimelineView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTimelineView()
    }
}

// MARK: UI setup
private extension VideoTimelineController {
    func setupTimelineView() {
        view.addSubview(timelineView)
        
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timelineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timelineView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            timelineView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
}
