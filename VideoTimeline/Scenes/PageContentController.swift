//
//  PageContentController.swift
//  VideoTimeline
//
//  Created by Aamir on 06/11/2024.
//

import Foundation
import UIKit

final class PageContentController: UIViewController {
    var pageIndex: Int = 0 {
        didSet {
            timelineView.pageNumberLabel.text = "Track \(pageIndex + 1)"
        }
    }
    
    private let timelineView = TimelineView(viewModel: TimelineViewModel())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimelineView()
    }
}

// MARK: Setup UI
private extension PageContentController {
    func setupTimelineView() {
        view.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timelineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timelineView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            timelineView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        timelineView.clipsToBounds = true
    }
}
