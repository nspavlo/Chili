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
    func fetch<T>(with endpoint: GiphyEndpoint) -> AnyPublisher<T, GiphyError> where T: Decodable {
        guard let url = endpoint.url else {
            preconditionFailure("Unable to construct a valid URL for given endpoint: \(endpoint)")
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
    public func fetchList(query: GiphySearchQuery) -> GiphyFetchable.Publisher {
        fetch(with: .search(for: query))
    }

    public func fetchTrendingList() -> GiphyFetchable.Publisher {
        fetch(with: .trending)
    }
}
