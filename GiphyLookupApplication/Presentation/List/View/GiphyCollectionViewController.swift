//
//  GiphyCollectionViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyCollectionViewController: UICollectionViewController {
    private let items: GiphyListItemViewModels

    init(items: GiphyListItemViewModels, collectionViewLayout: UICollectionViewLayout) {
        self.items = items
        super.init(collectionViewLayout: collectionViewLayout)
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

private extension GiphyCollectionViewController {
    func setup() {
        setupCollectionView()
        setupSearchController()
    }

    func setupCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        collectionView.register(cellType: GiphyCollectionViewCell.self)
        collectionView.register(
            supplementaryViewType: ActivityIndicatorCollectionReusableView.self,
            ofKind: UICollectionView.elementKindSectionFooter
        )
    }

    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search GIPHY"
        navigationItem.searchController = searchController
    }
}

// MARK: UICollectionViewDataSource

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        items.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GiphyCollectionViewCell
        let item = items[indexPath.item]
        cell.accessibilityValue = item.title
        cell.contentView.backgroundColor = .random
        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            as ActivityIndicatorCollectionReusableView
        return view
    }

    override func collectionView(
        _: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind _: String,
        at _: IndexPath
    ) {
        if let view = view as? ActivityIndicatorCollectionReusableView {
            view.startAnimating()
        }
    }

    override func collectionView(
        _: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind _: String,
        at _: IndexPath
    ) {
        if let view = view as? ActivityIndicatorCollectionReusableView {
            view.stopAnimating()
        }
    }
}

// MARK: UISearchResultsUpdating

extension GiphyCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}

// MARK: PinterestLayoutDelegate

extension GiphyCollectionViewController: PinterestCollectionViewLayoutDelegate {
    func collectionView(_: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.item]
        return CGFloat(item.height)
    }

    func collectionView(_: UICollectionView, heightForFooterAtIndexPath _: IndexPath) -> CGFloat {
        44.0
    }
}

// MARK: -

// MARK: Debug Helpers

private extension UIColor {
    static var random: UIColor {
        .init(hue: .random(in: 0 ... 1), saturation: 1, brightness: 1, alpha: 1)
    }
}
