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
    private(set) var hasMorePages = false

    private let giphyFetcher: GiphyFetchable
    private var giphyFetcherCancellable: Combine.Cancellable?
    private let actions: GiphyListViewModelActions

    private let currentQuerySubject = CurrentValueSubject<SearchQuery?, Never>(nil)
    private var currentQuerySubjectCancelable: Combine.Cancellable?

    private var offset: UInt = 0
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
            .compactMap { $0 }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { query in
                self.onLoadingStateChange?(true)
                self.resetContentPagination()
                self.fetchList(query: query, offset: self.offset)
            }
    }
}

// MARK: Pagination

private extension GiphyListController {
    func appendNewPage(from response: GiphyResponse) {
        hasMorePages = hasMorePages(with: response.pagination)
        data.append(contentsOf: response.data)
        items = data.map(GiphyListItemViewModel.init).uniqued()
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

        offset = UInt(data.count)
        fetchActiveList()
    }

    func didRequestListUpdate() {
        currentQuerySubject.send(nil)
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

    private func urls(for indexes: [Int]) -> [URL] {
        indexes.map { items[$0].url }
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
        currentQuerySubject.send(nil)
        resetContentPagination()

        onLoadingStateChange?(true)
        fetchTrendingList(offset: offset)
    }
}

// MARK: Private Methods

private extension GiphyListController {
    func fetchActiveList() {
        if let currentSearchQuery = currentQuerySubject.value {
            fetchList(query: currentSearchQuery, offset: offset)
        } else {
            fetchTrendingList(offset: offset)
        }
    }

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
}

// MARK: Adapter

private extension GiphyListItemViewModel {
    init(_ data: GIF) {
        let preview = data.images.fixedWidth
        self.init(title: data.title, width: preview.width.rawValue, height: preview.height.rawValue, url: preview.url)
    }
}

// MARK: Locale

private typealias Locale = String

private extension Locale {
    static let trendingListTitle = "Trending 🔥"
    static let searchBarPlaceholder = "Search GIPHY"
}
