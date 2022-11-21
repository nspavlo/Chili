//
//  GiphyDetailsViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import UIKit

// MARK: -

// MARK: Initialization

final class GiphyDetailsViewController: UIViewController {
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension GiphyDetailsViewController {
    func setup() {
        view.backgroundColor = .systemBackground
    }
}
