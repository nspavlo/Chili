//
//  GiphyContainerViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyContainerViewController: UIViewController {
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
        viewModel.viewDidLoad()
    }
}

// MARK: Private Methods

private extension GiphyContainerViewController {
    func setup() {
        setupViewBindings()
        setupSearchController()
    }

    func setupViewBindings() {
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

    func render(_ state: GiphyListViewModelState) {
        switch state {
        case .loading:
            let viewController = ActivityIndicatorViewController()
            replaceExisting(with: viewController, in: view)

        case let .result(.success(viewModels)):
            let collectionViewLayout = PinterestCollectionViewLayout()
            let viewController = GiphyCollectionViewController(
                viewModels: viewModels,
                collectionViewLayout: collectionViewLayout
            )
            collectionViewLayout.delegate = viewController
            replaceExisting(with: viewController, in: view)

        case let .result(.failure(error)):
            let viewController = ErrorViewController(error: error)
            replaceExisting(with: viewController, in: view)
        }
    }
}

// MARK: UISearchResultsUpdating

extension GiphyContainerViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}

// MARK: -

// MARK: UIViewController+Embed

extension UIViewController {
    func embed(_ child: UIViewController, in container: UIView) {
        addChild(child)
        child.view.frame = container.frame
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func replaceExisting(with child: UIViewController, in container: UIView) {
        removeAllEmbedded()
        embed(child, in: container)
    }

    func removeAllEmbedded() {
        for child in children {
            child.remove()
        }
    }
}
