//
//  GiphyFetchable.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine

public protocol GiphyFetchable {
    typealias Publisher = AnyPublisher<GiphyResponse, GiphyError>

    func fetchList(offset: UInt, query: SearchQuery) -> Publisher
    func fetchTrendingList(offset: UInt) -> Publisher
}
