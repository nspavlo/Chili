//
//  GiphyCollectionViewCell.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyCollectionViewCell: UICollectionViewCell {}

// MARK: Configuration

extension GiphyCollectionViewCell {
    func configure(with viewModel: GiphyListItemViewModel) {
        accessibilityValue = viewModel.title
        backgroundColor = .random
    }
}

// MARK: -

// MARK: Debug Helpers

private extension UIColor {
    static var random: UIColor {
        .init(hue: .random(in: 0 ... 1), saturation: 1, brightness: 1, alpha: 1)
    }
}
