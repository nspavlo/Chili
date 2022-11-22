//
//  GiphyCollectionViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyCollectionViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, GiphyListItemViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, GiphyListItemViewModel>

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, viewModel -> UICollectionViewCell? in
                if indexPath.row == self.viewModel.items.count - 1 {
                    self.viewModel.didLoadNextPage()
                }

                let cell = collectionView.dequeueReusableCell(for: indexPath) as GiphyCollectionViewCell
                cell.configure(with: viewModel)
                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else {
                return nil
            }

            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: indexPath
            ) as ActivityIndicatorCollectionReusableView
        }
        return dataSource
    }()

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
        setupDataSourceSnapshot()
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
                self?.collectionView.refreshControl?.beginRefreshing()
            } else {
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }

        viewModel.onListChange = { [weak self] in
            self?.setupDataSourceSnapshot()
        }
    }

    func setupDataSourceSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: Actions

private extension GiphyCollectionViewController {
    @objc func handleControlValueChanged(_: UIRefreshControl) {
        viewModel.didRequestListUpdate()
    }
}

// MARK: UICollectionViewDataSource

extension GiphyCollectionViewController {
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

// MARK: UICollectionViewDelegate

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
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
