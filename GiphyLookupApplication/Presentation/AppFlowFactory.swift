//
//  AppFlowFactory.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation
import GiphyLookup

// MARK: Initialization

final class AppFlowFactory {
    private var session: URLSessionConfiguration {
        let timeoutInterval: TimeInterval = 15
        let configuration: URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        return configuration
    }
}

// MARK: Factory Methods

extension AppFlowFactory {
    func makeGiphyFlowFactory() -> GiphyFlowFactory {
        GiphyFlowFactory(httpClient: URLSessionHTTPClient(session: URLSession(configuration: session)))
    }
}
