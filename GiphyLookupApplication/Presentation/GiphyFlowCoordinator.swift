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

extension GiphyFlowCoordinator: Coordinator {
    func start() {
        showTrendingList()
    }

    func showTrendingList() {
        let viewModel = GiphyListController(repository: giphyFlowFactory.createGiphyFetcher())
        let viewController = GiphyContainerViewController(viewModel: viewModel)

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
    }
}
