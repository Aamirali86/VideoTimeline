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
            pageNumberLabel.text = "Track \(pageIndex + 1)"
        }
    }
    
    private let timelineView = TimelineView()
    private let pageNumberLabel: UILabel = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimelineView()
        setupPageNumberLabel()
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
    }
    
    func setupPageNumberLabel() {
        view.addSubview(pageNumberLabel)
        NSLayoutConstraint.activate([
            pageNumberLabel.widthAnchor.constraint(equalToConstant: 160),
            pageNumberLabel.heightAnchor.constraint(equalToConstant: 60),
            pageNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageNumberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
