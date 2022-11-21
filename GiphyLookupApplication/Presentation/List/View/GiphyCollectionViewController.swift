//
//  GiphyCollectionViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyCollectionViewController: UICollectionViewController {
    private let viewModel: GiphyListViewModel

    init(viewModel: GiphyListViewModel, collectionViewLayout: UICollectionViewLayout) {
        self.viewModel = viewModel
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

// MARK: Setup

private extension GiphyCollectionViewController {
    func setup() {
        setupRefreshControlForScrollView()
        setupCollectionView()
        setupViewBindings()
        viewModel.onAppear()
    }

    func setupRefreshControlForScrollView() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleControlValueChanged(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func setupCollectionView() {
        collectionView.contentInset = UIEdgeInsets(inset: 2)
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        collectionView.register(cellType: GiphyCollectionViewCell.self)
        collectionView.register(
            supplementaryViewType: ActivityIndicatorCollectionReusableView.self,
            ofKind: UICollectionView.elementKindSectionFooter
        )
    }

    func setupViewBindings() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.collectionView.layoutSubviews()
                self?.collectionView.refreshControl?.beginRefreshing()
            } else {
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }

        viewModel.onListChange = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: Actions

private extension GiphyCollectionViewController {
    @objc func handleControlValueChanged(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            sender.endRefreshing()
        }
    }
}

// MARK: UICollectionViewDataSource

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.items.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GiphyCollectionViewCell
        let viewModel = viewModel.items[indexPath.item]
        cell.configure(with: viewModel)
        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            as ActivityIndicatorCollectionReusableView
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

// MARK: UICollectionViewDataSourcePrefetching

extension GiphyCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.startPrefetch(at: indexPaths.map(\.row))
    }

    func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.stopPrefetch(at: indexPaths.map(\.row))
    }
}

// MARK: UICollectionViewDelegate

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}

// MARK: PinterestCollectionViewLayoutDelegate

extension GiphyCollectionViewController: PinterestCollectionViewLayoutDelegate {
    func collectionView(_: UICollectionView, aspectRatioForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModel.items[indexPath.item]
        return CGFloat(viewModel.height) / CGFloat(viewModel.width)
    }

    func collectionView(_: UICollectionView, heightForFooterAtIndexPath _: IndexPath) -> CGFloat {
        44.0
    }
}
