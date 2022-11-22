//
//  GiphyFetcherTests.swift
//  GiphyLookupTests
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import Combine
import XCTest

@testable import GiphyLookup

// MARK: XCTestCase

final class GiphyFetcherTests: XCTestCase {
    func test_init_shouldNotExecuteAnyRequests() {
        let (_, spy) = makeSystemComponentsUnderTest()

        XCTAssertEqual(spy.requests.count, 0)
    }

    func test_search_shouldExecuteSearchRequest() {
        let url = URL(string: "https://api.giphy.com/v1/gifs/search?q=hey&offset=1&api_key=\(GiphyEndpoint.key)")
        let (sut, spy) = makeSystemComponentsUnderTest()

        _ = sut.fetchList(offset: 1, query: SearchQuery("hey")!)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

        XCTAssertEqual(spy.requests.first, url)
    }

    func test_trending_shouldExecuteTrendingRequest() {
        let url = URL(string: "https://api.giphy.com/v1/gifs/trending?offset=1&api_key=\(GiphyEndpoint.key)")
        let (sut, spy) = makeSystemComponentsUnderTest()

        _ = sut.fetchTrendingList(offset: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

        XCTAssertEqual(spy.requests.first, url)
    }

    private func makeSystemComponentsUnderTest() -> (GiphyFetcher, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = GiphyFetcher(httpClient: spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
}

// MARK: -

// MARK: Initialization

final class HTTPClientSpy {
    private(set) var requests = [URL]()
}

// MARK: HTTPClient

extension HTTPClientSpy: HTTPClient {
    struct FakeHTTPClientTask: GiphyLookup.HTTPClientTask {
        func cancel() {}
    }

    func fetch(from url: URL, completion _: @escaping CompletionHandler) -> GiphyLookup.HTTPClientTask {
        requests.append(url)
        return FakeHTTPClientTask()
    }
}
