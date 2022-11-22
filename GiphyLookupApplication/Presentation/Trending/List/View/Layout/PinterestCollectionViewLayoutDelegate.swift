//
//  PinterestCollectionViewLayoutDelegate.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import UIKit

protocol PinterestCollectionViewLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        aspectRatioForCellAtIndexPath indexPath: IndexPath
    ) -> CGFloat

    func collectionView(
        _ collectionView: UICollectionView,
        heightForFooterAtIndexPath indexPath: IndexPath
    ) -> CGFloat
}
