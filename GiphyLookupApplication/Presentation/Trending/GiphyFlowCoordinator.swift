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
}

// MARK: Private Methods

private extension GiphyFlowCoordinator {
    func showTrendingSearchList() {
        let viewModel = GiphyListController(
            giphyFetcher: giphyFlowFactory.createGiphyFetcher(),
            imagePrefetcher: giphyFlowFactory.createImagePrefetcher(),
            actions: GiphyListViewModelActions(showDetails: showDetails(for:), showError: showErrorAlert(_:))
        )

        let collectionViewLayout = PinterestCollectionViewLayout()
        let collectionViewController = GiphyCollectionViewController(
            viewModel: viewModel,
            collectionViewLayout: collectionViewLayout
        )
        collectionViewLayout.delegate = collectionViewController

        let searchContainerViewController = GiphySearchContainerViewController(
            viewModel: viewModel,
            childViewController: collectionViewController
        )

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([searchContainerViewController], animated: false)
    }

    func showDetails(for giphy: GIF) {
        let viewController = GiphyDetailsViewController(url: giphy.images.original.url)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showErrorAlert(_ error: Error) {
        let viewController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        navigationController.present(viewController, animated: true)
    }
}
