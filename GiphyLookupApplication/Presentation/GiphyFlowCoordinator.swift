//
//  GiphyFlowCoordinator.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import UIKit

// MARK: Initialization

final class GiphyFlowCoordinator {
    private let navigationController: UINavigationController
    private let giphyFlowFactory: GiphyFlowFactory
    private var subscriber: AnyCancellable?

    init(navigationController: UINavigationController, giphyFlowFactory: GiphyFlowFactory) {
        self.navigationController = navigationController
        self.giphyFlowFactory = giphyFlowFactory
    }
}

// MARK: Coordinator

extension GiphyFlowCoordinator: Coordinator {
    func start() {
        showGiphyCollectionViewController(with: [
            .init(title: "a-title", width: 500, height: 624, url: URL(string: "http://a-url.com")!),
            .init(title: "a-title", width: 306, height: 306, url: URL(string: "http://a-url.com")!),
            .init(title: "a-title", width: 260, height: 260, url: URL(string: "http://a-url.com")!),
            .init(title: "a-title", width: 084, height: 149, url: URL(string: "http://a-url.com")!),
            .init(title: "a-title", width: 110, height: 191, url: URL(string: "http://a-url.com")!),
        ])
        debugFetchTrendingList()
    }

    func showGiphyCollectionViewController(with items: GiphyListItemViewModels) {
        let collectionViewLayout = PinterestCollectionViewLayout()
        let viewController = GiphyCollectionViewController(items: items, collectionViewLayout: collectionViewLayout)
        viewController.title = "Trending 🔥"
        collectionViewLayout.delegate = viewController

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func debugFetchTrendingList() {
        subscriber = giphyFlowFactory.createGiphyFetcher()
            .fetchTrendingList()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        switch error {
                        case let .parsing(error):
                            print("parsing: \(error)")
                        case let .network(error):
                            print("parsing: \(error)")
                        }
                    }
                    print("receiveCompletion: \(completion)")
                },
                receiveValue: { value in
                    let items: GiphyListItemViewModels = value.data.map { data in
                        let preview = data.images.preview
                        return .init(title: data.title, width: preview.width, height: preview.height, url: preview.mp4)
                    }
                    self.showGiphyCollectionViewController(with: items)
                }
            )
    }
}
