//
//  AppSceneDelegate.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 18/11/2022.
//

import UIKit

// MARK: Initialization

final class AppSceneDelegate: UIResponder {
    var window: UIWindow?
    var coordinator: AppFlowCoordinator?
}

// MARK: Private Methods

extension AppSceneDelegate {
    func setupMainWindow(with navigationController: UINavigationController) {
        guard let window else {
            assertionFailure("Main `UIWindow` instance is missing")
            return
        }

        window.rootViewController = navigationController
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
    }

    func setupAppFlowCoordinator(with navigationController: UINavigationController) {
        coordinator = AppFlowCoordinator(
            navigationController: navigationController,
            appFlowFactory: AppFlowFactory()
        )
        coordinator?.start()
    }
}

// MARK: UIWindowSceneDelegate

extension AppSceneDelegate: UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        window = (scene as? UIWindowScene)
            .map(UIWindow.init(windowScene:))

        let navigationController = UINavigationController()
        setupAppFlowCoordinator(with: navigationController)
        setupMainWindow(with: navigationController)
    }
}
