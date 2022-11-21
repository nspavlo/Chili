//
//  GiphyCollectionViewController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: Initialization

final class GiphyCollectionViewController: UICollectionViewController {
    var didSelectItem: ((Int) -> Void)?
    var didLoadNextPage: (() -> Void)?

    private let viewModels: GiphyListItemViewModels

    init(viewModels: GiphyListItemViewModels, collectionViewLayout: UICollectionViewLayout) {
        self.viewModels = viewModels
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
        setupCollectionView()
    }
}

private extension GiphyCollectionViewController {
    func setupCollectionView() {
        collectionView.contentInset = UIEdgeInsets(inset: 2)
        collectionView.register(cellType: GiphyCollectionViewCell.self)
        collectionView.register(
            supplementaryViewType: ActivityIndicatorCollectionReusableView.self,
            ofKind: UICollectionView.elementKindSectionFooter
        )
    }
}

// MARK: UICollectionViewDataSource

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModels.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GiphyCollectionViewCell
        let viewModel = viewModels[indexPath.item]
        cell.configure(with: viewModel)

        if indexPath.row == viewModels.count - 1 {
            didLoadNextPage?()
        }

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

// MARK: UICollectionViewDelegate

extension GiphyCollectionViewController {
    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath.row)
    }
}

// MARK: PinterestLayoutDelegate

extension GiphyCollectionViewController: PinterestCollectionViewLayoutDelegate {
    func collectionView(_: UICollectionView, aspectRatioForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModels[indexPath.item]
        return CGFloat(viewModel.height) / CGFloat(viewModel.width)
    }

    func collectionView(_: UICollectionView, heightForFooterAtIndexPath _: IndexPath) -> CGFloat {
        44.0
    }
}
