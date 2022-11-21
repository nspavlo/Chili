//
//  GiphyContainerViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphySearchContainerViewController: UIViewController {
    private let viewModel: GiphyListViewModel

    init(viewModel: GiphyListViewModel) {
        self.viewModel = viewModel
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
        viewModel.onAppear()
    }
}

// MARK: Setup

private extension GiphySearchContainerViewController {
    func setup() {
        setupViewBindings()
        setupSearchController()
    }

    func setupViewBindings() {
        title = viewModel.title
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        navigationItem.searchController = searchController
    }
}

// MARK: Rendering

private extension GiphySearchContainerViewController {
    func render(_ state: GiphyListViewModelState) {
        switch state {
        case .loading:
            let viewController = GiphyCollectionViewController(
                viewModels: [],
                collectionViewLayout: UICollectionViewFlowLayout()
            )

            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(test(_:)), for: .valueChanged)
            viewController.collectionView.refreshControl = refreshControl

            DispatchQueue.main.async {
                refreshControl.beginRefreshing()
            }

            replaceExisting(with: viewController, in: view)

        case let .result(.success(viewModels)):
            let collectionViewLayout = PinterestCollectionViewLayout()
            let viewController = GiphyCollectionViewController(
                viewModels: viewModels,
                collectionViewLayout: collectionViewLayout
            )
            collectionViewLayout.delegate = viewController

            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(test), for: .valueChanged)
            viewController.collectionView.refreshControl = refreshControl
            viewController.didSelectItem = viewModel.didSelectItem(at:)
            viewController.didLoadNextPage = viewModel.didLoadNextPage
            replaceExisting(with: viewController, in: view)

        case let .result(.failure(error)):
            let viewController = ErrorViewController(error: error)
            replaceExisting(with: viewController, in: view)
        }
    }
}

extension GiphySearchContainerViewController {
    @objc func test(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            sender.endRefreshing()
        }
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
