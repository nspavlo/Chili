//
//  UIEdgeInsets+Inset.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import UIKit

extension UIEdgeInsets {
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}
