//
//  ErrorViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class ErrorViewController: UIViewController {
    private let label = UILabel()
    private let error: Error

    init(error: Error) {
        self.error = error
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = error.localizedDescription
        label.textAlignment = .center
        label.numberOfLines = 0
        view.addSubview(label)
    }

    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        label.frame = view.bounds.insetBy(dx: 16, dy: 16)
    }
}
