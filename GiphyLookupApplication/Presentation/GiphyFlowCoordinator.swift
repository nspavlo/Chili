//
//  GiphyFlowCoordinator.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import GiphyLookup
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
        showTrendingSearchList()
    }

    func showTrendingSearchList() {
        let viewModel = GiphyListController(
            giphyFetcher: giphyFlowFactory.createGiphyFetcher(),
            actions: GiphyListViewModelActions(showGiphyDetails: showGiphyDetails(giphy:))
        )
        let viewController = GiphySearchContainerViewController(viewModel: viewModel)

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showGiphyDetails(giphy _: GiphyResponse.GIF) {
        let viewController = GiphyDetailsViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
