//
//  AppFlowFactory.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import GiphyLookup

import Foundation

// MARK: Initialization

final class AppFlowFactory {
    private var session: URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        return configuration
    }
}

// MARK: Factory Methods

extension AppFlowFactory {
    func makeGiphyFlowFactory() -> GiphyFlowFactory {
        GiphyFlowFactory(httpClient: URLSessionHTTPClient(session: URLSession(configuration: session)))
    }
}
