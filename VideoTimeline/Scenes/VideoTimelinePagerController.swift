//
//  VideoTimelinePagerController.swift
//  VideoTimeline
//
//  Created by Aamir on 06/11/2024.
//

import UIKit

final class VideoTimelinePagerController: UIPageViewController {
    var pages: [PageContentController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPager()
    }
}

private extension VideoTimelinePagerController {
    func setupPager() {
        dataSource = self
        createPages()

        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func createPages() {
        // total number of pages
        for i in 0..<5 {
            let page = PageContentController()
            page.pageIndex = i
            pages.append(page)
        }
    }
}

extension VideoTimelinePagerController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! PageContentController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! PageContentController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}
