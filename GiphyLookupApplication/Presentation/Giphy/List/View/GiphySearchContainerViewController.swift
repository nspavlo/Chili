//
//  GiphyContainerViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphySearchContainerViewController: UIViewController {
    private let viewModel: GiphySearchViewModel
    private let childViewController: UIViewController

    init(viewModel: GiphySearchViewModel, childViewController: UIViewController) {
        self.viewModel = viewModel
        self.childViewController = childViewController
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
}

// MARK: Setup

private extension GiphySearchContainerViewController {
    func setup() {
        title = viewModel.title
        embed(childViewController, in: view)
        setupSearchController()
    }

    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        navigationItem.searchController = searchController
    }
}

// MARK: UISearchResultsUpdating

extension GiphySearchContainerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            viewModel.dismissSearchQuery()
        } else {
            viewModel.updateSearchQuery(searchController.searchBar.text)
        }
    }
}
