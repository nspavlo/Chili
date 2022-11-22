//
//  AppFlowCoordinator.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit.UINavigationController

// MARK: Initialization

final class AppFlowCoordinator {
    private let navigationController: UINavigationController
    private let appFlowFactory: AppFlowFactory

    init(navigationController: UINavigationController, appFlowFactory: AppFlowFactory) {
        self.navigationController = navigationController
        self.appFlowFactory = appFlowFactory
    }
}

// MARK: Coordinator

extension AppFlowCoordinator: Coordinator {
    func start() {
        let giphyFlowFactory = appFlowFactory.makeGiphyFlowFactory()
        let coordinator = giphyFlowFactory.makeGiphyFlowCoordinator(with: navigationController)
        coordinator.start()
    }
}
