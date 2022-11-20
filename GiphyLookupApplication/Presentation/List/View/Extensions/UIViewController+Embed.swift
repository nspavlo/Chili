//
//  UIViewController+Embed.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

extension UIViewController {
    func embed(_ child: UIViewController, in container: UIView) {
        addChild(child)
        child.view.frame = container.frame
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func replaceExisting(with child: UIViewController, in container: UIView) {
        removeAllEmbedded()
        embed(child, in: container)
    }

    func removeAllEmbedded() {
        for child in children {
            child.remove()
        }
    }
}
