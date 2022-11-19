//
//  AppSceneDelegate.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 18/11/2022.
//

import UIKit

// MARK: Initialization

final class AppSceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: Private Methods

extension AppSceneDelegate {
    func setupMainWindow(with navigationController: UINavigationController) {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func setupAppFlowCoordinator(with _: UINavigationController) {}
}

// MARK: UIWindowSceneDelegate

extension AppSceneDelegate: UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        window = (scene as? UIWindowScene)
            .map(UIWindow.init(windowScene:))

        let viewController = GiphyCollectionViewController()
        viewController.title = "Giphy Lookup"
        let navigationController = UINavigationController(rootViewController: viewController)
        setupAppFlowCoordinator(with: navigationController)
        setupMainWindow(with: navigationController)
    }
}

// MARK: -

// MARK: Initialization

final class GiphyCollectionViewController: UICollectionViewController {
    struct ViewModel {
        let imageHeight: CGFloat
    }

    private let viewModels: [ViewModel] = [
        .init(imageHeight: 100),
        .init(imageHeight: 80),
        .init(imageHeight: 50),
        .init(imageHeight: 90),
        .init(imageHeight: 100),
    ]

    init() {
        let layout = PinterestCollectionViewLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        collectionView.register(cellType: GiphyCollectionViewCell.self)
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
        cell.contentView.backgroundColor = .random
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension GiphyCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        fatalError("Unimplemented")
    }
}

// MARK: PinterestLayoutDelegate

extension GiphyCollectionViewController: PinterestCollectionViewLayoutDelegate {
    func collectionView(_: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModels[indexPath.item]
        return viewModel.imageHeight
    }
}

// MARK: -

// MARK: Initialization

final class GiphyCollectionViewCell: UICollectionViewCell {}

// MARK: Reusable

extension GiphyCollectionViewCell: Reusable {}

// MARK: -

// MARK: Protocol

protocol PinterestCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat
}

// MARK: -

// MARK: Initialization

final class PinterestCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: PinterestCollectionViewLayoutDelegate?

    private let columns = 2
    private let padding: CGFloat = 2

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = .zero

    private var contentWidth: CGFloat {
        guard let collectionView else {
            return 0
        }

        let contentInset = collectionView.contentInset
        return collectionView.bounds.width - (contentInset.left + contentInset.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView, let delegate, cache.isEmpty else {
            return
        }

        let columnWidth = contentWidth / CGFloat(columns)
        var xOffset: [CGFloat] = []
        for column in 0 ..< columns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        let section = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: columns)

        for item in 0 ..< collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)
            let cellHeight = delegate.collectionView(collectionView, heightForCellAtIndexPath: indexPath)
            let height = padding * 2 + cellHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame.insetBy(dx: padding, dy: padding)
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (columns - 1) ? (column + 1) : 0
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

// MARK: -

// MARK: Helpers

extension UIColor {
    static var random: UIColor {
        .init(hue: .random(in: 0 ... 1), saturation: 1, brightness: 1, alpha: 1)
    }
}
