//
//  UICollectionView+Reusable.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

// MARK: UICollectionViewCell

extension UICollectionView {
    final func register(cellType: (some UICollectionViewCell & Reusable).Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    final func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath,
        cellType: T.Type = T.self
    ) -> T where T: Reusable {
        let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = cell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self)."
            )
        }
        return cell
    }
}

// MARK: UICollectionReusableView

extension UICollectionView {
    final func register(
        supplementaryViewType: (some UICollectionReusableView & Reusable).Type,
        ofKind elementKind: String
    ) {
        register(
            supplementaryViewType.self,
            forSupplementaryViewOfKind: elementKind,
            withReuseIdentifier: supplementaryViewType.reuseIdentifier
        )
    }

    final func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind elementKind: String,
        for indexPath: IndexPath,
        viewType: T.Type = T.self
    ) -> T where T: Reusable {
        let view = dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: viewType.reuseIdentifier,
            for: indexPath
        )
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier)"
            )
        }
        return typedView
    }
}
