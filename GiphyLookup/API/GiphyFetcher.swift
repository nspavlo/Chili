//
//  GiphyFetcher.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation

// MARK: Initialization

public final class GiphyFetcher {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}

// MARK: Private Methods

private extension GiphyFetcher {
    func fetch<T>(with components: URLComponents) -> AnyPublisher<T, GiphyError> where T: Decodable {
        guard let url = components.url else {
            preconditionFailure("Unable to construct a valid URL with given components: \(components)")
        }

        return httpClient
            .fetchPublisher(url: url)
            .mapError(GiphyError.network)
            .flatMap(decode)
            .eraseToAnyPublisher()
    }
}

// MARK: GiphyFetchable

extension GiphyFetcher: GiphyFetchable {
    public func fetchList(query: String, page: Int) -> GiphyFetchable.Publisher {
        fetch(with: GiphyEndpoint.makeQueryListComponents(query: query, page: page))
    }

    public func fetchTrendingList() -> GiphyFetchable.Publisher {
        fetch(with: GiphyEndpoint.makeTrendingListComponents())
    }
}
