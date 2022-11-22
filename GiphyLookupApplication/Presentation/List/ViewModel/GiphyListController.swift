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

    private var response: GiphyResponse?

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
                self.fetchList(query: query)
            }
    }
}

// MARK: GiphyListViewModelInput

extension GiphyListController: GiphyListViewModelInput {
    func onAppear() {
        fetchTrendingList()
    }

    func didRequestListUpdate() {
        fetchTrendingList()
    }

    func didSelectItem(at index: Int) {
        guard let response else {
            fatalError("Can't select non loaded item")
        }

        let item = response.data[index]
        actions.showDetails(item)
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
        fetchTrendingList()
    }
}

// MARK: Private Methods

private extension GiphyListController {
    func fetchTrendingList() {
        giphyFetcherCancellable = fetch(from: giphyFetcher.fetchTrendingList())
    }

    func fetchList(query: SearchQuery) {
        giphyFetcherCancellable = fetch(from: giphyFetcher.fetchList(query: query))
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
                self.items = response.data.map { data in
                    let preview = data.images.fixedWidth
                    return .init(
                        title: data.title,
                        width: preview.width.rawValue,
                        height: preview.height.rawValue,
                        url: preview.url
                    )
                }
                self.response = response
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
