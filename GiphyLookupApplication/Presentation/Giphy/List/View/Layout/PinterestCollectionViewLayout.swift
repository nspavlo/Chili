//
//  PinterestCollectionViewLayout.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

final class PinterestCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: PinterestCollectionViewLayoutDelegate?

    private let numberOfColumns = 2
    private let padding: CGFloat = 2

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentViewHeight: CGFloat = .zero
    private var contentViewWidth: CGFloat {
        guard let collectionView else {
            return .zero
        }

        let contentInset = collectionView.contentInset
        return collectionView.bounds.width - (contentInset.left + contentInset.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentViewWidth, height: contentViewHeight)
    }

    override func prepare() {
        guard let collectionView, let delegate, cache.isEmpty else {
            return
        }

        let columnViewWidth = contentViewWidth / CGFloat(numberOfColumns)
        var column = 0

        var offsets: [CGPoint] = (0 ..< numberOfColumns)
            .map { CGPoint(x: CGFloat($0) * columnViewWidth, y: 0) }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let columnViewHeight = delegate.collectionView(collectionView, heightForCellAtIndexPath: indexPath)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(origin: offsets[column], size: CGSize(width: columnViewWidth, height: columnViewHeight))
            attributes.frame = frame.insetBy(dx: padding, dy: padding)
            cache.append(attributes)

            contentViewHeight = max(contentViewHeight, frame.maxY)
            offsets[column].y += columnViewHeight
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache[indexPath.item]
    }
}
