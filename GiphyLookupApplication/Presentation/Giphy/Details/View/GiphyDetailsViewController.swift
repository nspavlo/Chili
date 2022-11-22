//
//  GiphyDetailsViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import Nuke
import NukeUI
import UIKit

// MARK: Initialization

final class GiphyDetailsViewController: UIViewController {
    private let lazyImageView = LazyImageView()
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lazyImageView.frame = view.frame
    }
}

// MARK: Setup

private extension GiphyDetailsViewController {
    func setup() {
        lazyImageView.backgroundColor = .secondarySystemBackground
        lazyImageView.placeholderView = UIActivityIndicatorView()
        lazyImageView.url = url
        lazyImageView.contentMode = .center
        view.addSubview(lazyImageView)
    }
}
