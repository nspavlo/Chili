//
//  GiphyCollectionViewCell.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Nuke
import NukeUI
import UIKit

// MARK: Initialization

final class GiphyCollectionViewCell: UICollectionViewCell {
    private let lazyImageView = LazyImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()
        lazyImageView.reset()
    }

    // MARK: UIView

    override func layoutSubviews() {
        super.layoutSubviews()
        lazyImageView.frame = bounds
    }
}

// MARK: Setup

private extension GiphyCollectionViewCell {
    func setup() {
        backgroundColor = .secondarySystemBackground
        lazyImageView.placeholderView = UIActivityIndicatorView()
        addSubview(lazyImageView)
    }
}

// MARK: Configuration

extension GiphyCollectionViewCell {
    func configure(with viewModel: GiphyListItemViewModel) {
        accessibilityLabel = viewModel.title
        lazyImageView.url = viewModel.url
    }
}
