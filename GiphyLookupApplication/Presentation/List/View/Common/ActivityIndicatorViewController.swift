//
//  ActivityIndicatorViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class ActivityIndicatorViewController: UIViewController {
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicatorView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicatorView.stopAnimating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicatorView.center = view.center
    }
}
