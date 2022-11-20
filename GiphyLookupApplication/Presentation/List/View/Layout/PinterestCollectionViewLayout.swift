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

    private var itemAttributesCache: [UICollectionViewLayoutAttributes] = []
    private var supplementaryViewAttributesCache: [UICollectionViewLayoutAttributes] = []

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
        super.prepare()

        guard
            let collectionView,
            let delegate,
            itemAttributesCache.isEmpty,
            supplementaryViewAttributesCache.isEmpty
        else {
            return
        }

        let columnViewWidth = contentViewWidth / CGFloat(numberOfColumns)
        var column = 0

        var offsets: [CGPoint] = (0 ..< numberOfColumns)
            .map { CGPoint(x: CGFloat($0) * columnViewWidth, y: 0) }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let heightForCell = delegate.collectionView(collectionView, heightForCellAtIndexPath: indexPath)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(origin: offsets[column], size: CGSize(width: columnViewWidth, height: heightForCell))
            attributes.frame = frame.insetBy(dx: padding, dy: padding)
            itemAttributesCache.append(attributes)

            offsets[column].y += heightForCell
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }

        let footerIndexPath = IndexPath(item: 0, section: 0)
        let attributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            with: footerIndexPath
        )

        let heightForFooter = delegate.collectionView(collectionView, heightForFooterAtIndexPath: footerIndexPath)
        let longestColumnVerticalPosition: CGFloat = offsets.map(\.y).max() ?? 0.0
        let frame = CGRect(x: 0.0, y: longestColumnVerticalPosition, width: contentViewWidth, height: heightForFooter)
        attributes.frame = frame.insetBy(dx: padding, dy: padding)
        supplementaryViewAttributesCache.append(attributes)
        contentViewHeight = max(contentViewHeight, frame.maxY)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in itemAttributesCache where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }

        for attributes in supplementaryViewAttributesCache where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        itemAttributesCache[indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return nil }

        return supplementaryViewAttributesCache[indexPath.section]
    }
}
