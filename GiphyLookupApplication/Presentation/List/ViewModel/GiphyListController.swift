//
//  GiphyListController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation
import GiphyLookup
import Nuke

// MARK: Initialization

final class GiphyListController: GiphyListViewModelOutput {
    var onLoadingStateChange: ((Bool) -> Void)?
    var onListChange: (() -> Void)?

    private(set) var items: GiphyListItemViewModels = []

    private let giphyFetcher: GiphyFetchable
    private var giphyFetcherCancellable: Combine.Cancellable?
    private let actions: GiphyListViewModelActions

    private let currentQuerySubject = PassthroughSubject<SearchQuery, Never>()
    private var currentQuerySubjectCancelable: Combine.Cancellable?

    private var offset: UInt = 0
    private var hasMorePages = false
    private var currentSearchQuery: SearchQuery?
    private var data = [GIF]()

    private let prefetcher = ImagePrefetcher()

    init(giphyFetcher: GiphyFetchable, actions: GiphyListViewModelActions) {
        self.giphyFetcher = giphyFetcher
        self.actions = actions
        setup()
    }
}

// MARK: Setup

private extension GiphyListController {
    func setup() {
        currentQuerySubjectCancelable = currentQuerySubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { query in
                self.onLoadingStateChange?(true)
                self.currentSearchQuery = query
                self.resetContentPagination()
                self.fetchList(query: query, offset: self.offset)
            }
    }
}

// MARK: Pagination

private extension GiphyListController {
    func appendNewPage(from response: GiphyResponse) {
        hasMorePages = hasMorePages(with: response.pagination)
        offset = response.pagination.count
        data.append(contentsOf: response.data)
        items = data.map { data in
            let preview = data.images.fixedWidth
            return .init(
                title: data.title,
                width: preview.width.rawValue,
                height: preview.height.rawValue,
                url: preview.url
            )
        }
    }

    func hasMorePages(with pagination: Pagination) -> Bool {
        pagination.totalCount > pagination.count
    }

    func resetContentPagination() {
        offset = 0
        data = []
    }
}

// MARK: GiphyListViewModelInput

extension GiphyListController: GiphyListViewModelInput {
    func onAppear() {
        fetchTrendingList(offset: offset)
    }

    func didLoadNextPage() {
        guard hasMorePages else { return }

        if let currentSearchQuery {
            fetchList(query: currentSearchQuery, offset: offset)
        } else {
            fetchTrendingList(offset: offset)
        }
    }

    func didRequestListUpdate() {
        currentSearchQuery = nil
        resetContentPagination()
        fetchTrendingList(offset: offset)
    }

    func didSelectItem(at index: Int) {
        actions.showDetails(data[index])
    }

    func startPrefetch(at indexes: [Int]) {
        prefetcher.startPrefetching(with: urls(for: indexes))
    }

    func stopPrefetch(at indexes: [Int]) {
        prefetcher.stopPrefetching(with: urls(for: indexes))
    }
}

// MARK: GiphySearchViewModel

extension GiphyListController: GiphySearchViewModel {
    var title: String { .trendingListTitle }
    var searchBarPlaceholder: String { .searchBarPlaceholder }

    func updateSearchQuery(_ query: String?) {
        guard let query = SearchQuery(query) else {
            return
        }

        currentQuerySubject.send(query)
    }

    func dismissSearchQuery() {
        currentSearchQuery = nil
        resetContentPagination()
        fetchTrendingList(offset: offset)
    }
}

// MARK: Private Methods

private extension GiphyListController {
    func fetchTrendingList(offset: UInt) {
        giphyFetcherCancellable = fetch(from: giphyFetcher.fetchTrendingList(offset: offset))
    }

    func fetchList(query: SearchQuery, offset: UInt) {
        giphyFetcherCancellable = fetch(from: giphyFetcher.fetchList(offset: offset, query: query))
    }

    func fetch(from giphyFetcher: GiphyFetchable.Publisher) -> AnyCancellable {
        giphyFetcher
            .receive(on: RunLoop.main)
            .sink { completion in
                self.onLoadingStateChange?(false)

                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.actions.showError(error)
                }
            }
            receiveValue: { response in
                self.appendNewPage(from: response)
                self.onListChange?()
            }
    }

    func urls(for indexes: [Int]) -> [URL] {
        indexes.map { items[$0].url }
    }
}

// MARK: Locale

private typealias Locale = String

private extension Locale {
    static let trendingListTitle = "Trending 🔥"
    static let searchBarPlaceholder = "Search GIPHY"
}
