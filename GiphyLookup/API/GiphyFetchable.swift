//
//  GiphyFetchable.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine

public protocol GiphyFetchable {
    typealias Publisher = AnyPublisher<GiphyResponse, GiphyError>

    func fetchList(query: SearchQuery) -> Publisher
    func fetchTrendingList() -> Publisher
}


// MARK: Models

public struct SearchQuery {
    let value: String

    public init?(_ string: String?) {
        guard let string, !string.isEmpty else {
            return nil
        }

        value = string
    }
}
