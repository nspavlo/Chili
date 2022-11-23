//
//  GiphyFetchableSpy.swift
//  GiphyLookupApplicationTests
//
//  Created by Jans Pavlovs on 23/11/2022.
//

import Combine
import Foundation

@testable import GiphyLookup

// MARK: Initialization

final class GiphyFetchableSpy {
    enum Request: Equatable {
        case search(SearchQuery)
        case trending(offset: UInt)
    }

    private(set) var fetchListPassthroughSubject = PassthroughSubject<GiphyResponse, GiphyError>()
    private(set) var fetchTrendingListPassthroughSubject = PassthroughSubject<GiphyResponse, GiphyError>()
    private(set) var requests = [Request]()

    var fetchListCompletion: (() -> Void)?
    var fetchTrendingListCompletion: (() -> Void)?
}

// MARK: GiphyFetchable

extension GiphyFetchableSpy: GiphyFetchable {
    func fetchList(offset _: UInt, query: SearchQuery) -> GiphyFetchable.Publisher {
        requests.append(.search(query))
        fetchListCompletion?()
        return fetchListPassthroughSubject
            .eraseToAnyPublisher()
    }

    func fetchTrendingList(offset: UInt) -> GiphyFetchable.Publisher {
        requests.append(.trending(offset: offset))
        fetchTrendingListCompletion?()
        return fetchTrendingListPassthroughSubject
            .eraseToAnyPublisher()
    }
}

// MARK: Fake Behaviour

extension GiphyFetchableSpy {
    func completeTrendingFetch(
        withEntries data: [GIF],
        pagination: Pagination = .init(count: 0, offset: 0, totalCount: 0)
    ) {
        let response = GiphyResponse(data: data, pagination: pagination)
        fetchTrendingListPassthroughSubject.send(response)
    }

    func completeTrendingFetch(withError error: NSError) {
        fetchTrendingListPassthroughSubject.send(completion: .failure(GiphyError.network(underlayingError: error)))
    }
}
