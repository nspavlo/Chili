//
//  GiphyFlowCoordinator.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyFlowCoordinator {
    private let navigationController: UINavigationController
    private let giphyFlowFactory: GiphyFlowFactory

    init(navigationController: UINavigationController, giphyFlowFactory: GiphyFlowFactory) {
        self.navigationController = navigationController
        self.giphyFlowFactory = giphyFlowFactory
    }
}

// MARK: Coordinator

extension GiphyFlowCoordinator {
    func start() {
        let collectionViewLayout = PinterestCollectionViewLayout()
        let viewController = GiphyCollectionViewController(
            items: [
                .init(title: "1", height: 200, url: URL(string: "http://a-url.com")!),
                .init(title: "2", height: 180, url: URL(string: "http://a-url.com")!),
                .init(title: "3", height: 120, url: URL(string: "http://a-url.com")!),
                .init(title: "4", height: 240, url: URL(string: "http://a-url.com")!),
                .init(title: "5", height: 200, url: URL(string: "http://a-url.com")!),
            ],
            collectionViewLayout: collectionViewLayout
        )
        viewController.title = "Trending 🔥"
        collectionViewLayout.delegate = viewController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
    }
}
