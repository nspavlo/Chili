//
//  PinterestCollectionViewLayout.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

final class PinterestCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: PinterestCollectionViewLayoutDelegate?

    private let columnCount = 2
    private let padding: CGFloat = 2

    private var cellLayoutAttributes = [UICollectionViewLayoutAttributes]()
    private var supplementaryViewLayoutAttributes = [UICollectionViewLayoutAttributes]()
    private var columnHeights = [CGFloat]()

    private var contentViewWidth: CGFloat {
        guard let collectionView else {
            return 0
        }

        let contentInset = collectionView.contentInset
        return collectionView.bounds.width - (contentInset.left + contentInset.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentViewWidth, height: columnHeights.first ?? 0)
    }

    override func prepare() {
        super.prepare()

        guard let collectionView, let delegate else {
            return
        }

        guard collectionView.numberOfSections == 1 else {
            preconditionFailure("Current \(self) implementation can't render multi section layout")
        }

        cellLayoutAttributes.removeAll(keepingCapacity: false)
        supplementaryViewLayoutAttributes.removeAll(keepingCapacity: false)
        columnHeights.removeAll(keepingCapacity: false)

        for _ in 0 ..< columnCount {
            columnHeights.append(0)
        }

        let columnWidth = contentViewWidth / CGFloat(columnCount)
        var offsets: [CGPoint] = (0 ..< columnCount)
            .map { CGPoint(x: CGFloat($0) * columnWidth, y: 0) }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let columnIndex = shortestColumnIndex()
            let indexPath = IndexPath(item: item, section: 0)
            let aspectRatio = delegate.collectionView(collectionView, aspectRatioForCellAtIndexPath: indexPath)
            let cellHeight = columnWidth * aspectRatio

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(origin: offsets[columnIndex], size: CGSize(width: columnWidth, height: cellHeight))
            attributes.frame = frame.insetBy(dx: padding, dy: padding)
            cellLayoutAttributes.append(attributes)

            offsets[columnIndex].y += cellHeight
            columnHeights[columnIndex] = attributes.frame.maxY + padding
        }

        let footerIndexPath = IndexPath(item: 0, section: 0)
        let attributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            with: footerIndexPath
        )

        let footerHeight = delegate.collectionView(collectionView, heightForFooterAtIndexPath: footerIndexPath)
        let longestColumnVerticalPosition: CGFloat = offsets.map(\.y).max() ?? 0.0
        let frame = CGRect(x: 0.0, y: longestColumnVerticalPosition, width: contentViewWidth, height: footerHeight)
        attributes.frame = frame.insetBy(dx: padding, dy: padding)
        supplementaryViewLayoutAttributes.append(attributes)
        columnHeights[0] = attributes.frame.maxY + padding
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in cellLayoutAttributes where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }

        for attributes in supplementaryViewLayoutAttributes where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }

        return visibleLayoutAttributes
    }
}

// MARK: Private Methods

private extension PinterestCollectionViewLayout {
    func shortestColumnIndex() -> Int {
        var index = 0
        var shortestHeight = CGFLOAT_MAX

        for (idx, height) in columnHeights.enumerated() where height < shortestHeight {
            shortestHeight = height
            index = idx
        }

        return index
    }
}
