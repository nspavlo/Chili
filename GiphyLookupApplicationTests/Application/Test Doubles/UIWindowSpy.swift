//
//  UIWindowSpy.swift
//  GiphyLookupApplicationTests
//
//  Created by Jans Pavlovs on 18/11/2022.
//

import UIKit.UIWindow

final class UIWindowSpy: UIWindow {
    private(set) var makeKeyAndVisibleCallCount = 0

    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()
        makeKeyAndVisibleCallCount += 1
    }
}
