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
}

// MARK: Private Methods

extension AppSceneDelegate {
    func setupMainWindow(with navigationController: UINavigationController) {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func setupAppFlowCoordinator(with navigationController: UINavigationController) {
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
        viewController.title = "Giphy Lookup"
        collectionViewLayout.delegate = viewController
        navigationController.setViewControllers([viewController], animated: false)
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
