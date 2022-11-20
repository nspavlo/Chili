//
//  GiphyEndpoint.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

// MARK: Endpoints

enum GiphyEndpoint {
    static let scheme = "https"
    static let host = "api.giphy.com"
    static let path = "/v1/gifs"
    static let key = "D1OIHpdq1qe36SHbpl0hgwQxT1jOluZm"
}

// MARK: Factory Methods

extension GiphyEndpoint {
    static func makeEndpointComponents(with path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = GiphyEndpoint.scheme
        components.host = GiphyEndpoint.host
        components.path = GiphyEndpoint.path + path
        return components
    }

    static func makeTrendingListComponents() -> URLComponents {
        var components = makeEndpointComponents(with: "/trending")
        components.queryItems = [
            URLQueryItem(name: "api_key", value: GiphyEndpoint.key),
        ]
        return components
    }

    static func makeQueryListComponents(query: String, page _: Int) -> URLComponents {
        var components = makeEndpointComponents(with: "/search")
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "api_key", value: GiphyEndpoint.key),
        ]
        return components
    }
}
