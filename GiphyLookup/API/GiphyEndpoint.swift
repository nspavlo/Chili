//
//  GiphyEndpoint.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

// MARK: Initialization

struct GiphyEndpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

// MARK: Available Endpoints

extension GiphyEndpoint {
    static let key = "D1OIHpdq1qe36SHbpl0hgwQxT1jOluZm"

    static func trending(offset: UInt) -> Self {
        .init(
            path: "/trending",
            queryItems: [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "api_key", value: Self.key),
            ]
        )
    }

    static func search(offset: UInt, for query: SearchQuery) -> Self {
        .init(
            path: "/search",
            queryItems: [
                URLQueryItem(name: "q", value: query.value),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "api_key", value: Self.key),
            ]
        )
    }
}

// MARK: Factory Methods

extension GiphyEndpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.giphy.com"
        components.path = "/v1/gifs" + path
        components.queryItems = queryItems
        return components.url
    }
}
