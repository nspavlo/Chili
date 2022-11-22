//
//  GiphyFlowFactory.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import GiphyLookup
import UIKit.UINavigationController

// MARK: Initialization

final class GiphyFlowFactory {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}

// MARK: Factory Methods

extension GiphyFlowFactory {
    func makeGiphyFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        GiphyFlowCoordinator(navigationController: navigationController, giphyFlowFactory: self)
    }

    func createGiphyFetcher() -> GiphyFetchable {
        GiphyFetcher(httpClient: httpClient)
    }
}
