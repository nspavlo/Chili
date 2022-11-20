//
//  AppFlowFactory.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import GiphyLookup

// MARK: Initialization

final class AppFlowFactory {
    lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: .shared)
}

// MARK: Factory Methods

extension AppFlowFactory {
    func makeGiphyFlowFactory() -> GiphyFlowFactory {
        GiphyFlowFactory(httpClient: httpClient)
    }
}
