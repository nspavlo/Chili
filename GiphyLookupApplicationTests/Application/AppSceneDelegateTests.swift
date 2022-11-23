//
//  AppSceneDelegateTests.swift
//  GiphyLookupApplicationTests
//
//  Created by Jans Pavlovs on 18/11/2022.
//

import XCTest

@testable import GiphyLookupApplication

// MARK: XCTestCase

final class AppSceneDelegateTests: XCTestCase {
    func test_scene_whenSettingUpMainWindow_shouldCallMakeKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = makeSystemComponentsUnderTest(with: window)

        sut.setupMainWindow(with: UINavigationController())

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }

    func test_scene_whenSettingUpMainWindow_shouldSetupNavigationControllerAsRootViewController() {
        let navigationController = UINavigationController()
        let sut = makeSystemComponentsUnderTest(with: UIWindow())

        sut.setupMainWindow(with: navigationController)

        XCTAssertEqual(sut.window?.rootViewController, navigationController)
    }

    func test_scene_whenStartingUpApplicationFlowCoordinator_shouldSetupInitialViewController() {
        let navigationController = UINavigationController()
        let sut = makeSystemComponentsUnderTest(with: UIWindow())

        sut.setupMainWindow(with: navigationController)
        sut.setupAppFlowCoordinator(with: navigationController)

        XCTAssertTrue(sut.window?.rootViewController?.children.first is GiphySearchContainerViewController)
    }
}

// MARK: -

// MARK: Factory Methods

private extension AppSceneDelegateTests {
    func makeSystemComponentsUnderTest(with window: UIWindow) -> AppSceneDelegate {
        let sut = AppSceneDelegate()
        sut.window = window
        return sut
    }
}
