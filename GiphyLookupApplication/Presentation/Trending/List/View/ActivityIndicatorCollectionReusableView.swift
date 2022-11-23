//
//  ActivityIndicatorCollectionReusableView.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class ActivityIndicatorCollectionReusableView: UICollectionReusableView {
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    // MARK: UICollectionReusableView

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicatorView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.frame = bounds
    }
}

// MARK: Public Methods

extension ActivityIndicatorCollectionReusableView {
    var isAnimating: Bool {
        activityIndicatorView.isAnimating
    }

    func startAnimating() {
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}
