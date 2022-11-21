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

// MARK: Actions

final class GiphyListViewModelActions {
    let showDetails: (GIF) -> Void
    let showError: (Error) -> Void

    init(showDetails: @escaping (GIF) -> Void, showError: @escaping (Error) -> Void) {
        self.showDetails = showDetails
        self.showError = showError
    }
}

// MARK: Initialization

final class GiphyListController: GiphyListViewModelOutput {
    var onLoadingStateChange: ((Bool) -> Void)?
    var onListChange: (() -> Void)?

    var items: GiphyListItemViewModels {
        response?.data.map { data in
            let preview = data.images.fixedWidth
            return .init(
                title: data.title,
                width: preview.width.rawValue,
                height: preview.height.rawValue,
                url: preview.url
            )
        } ?? []
    }

    private let giphyFetcher: GiphyFetchable
    private var giphyFetcherCancellable: Combine.Cancellable?
    private let actions: GiphyListViewModelActions
    private var response: GiphyResponse?

    private let currentQuerySubject = PassthroughSubject<SearchQuery, Never>()
    private var currentQuerySubjectCancelable: Combine.Cancellable?

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

    func startPrefetch(at indexes: [Int]) {
        let urls = indexes.map { items[$0].url }
        prefetcher.startPrefetching(with: urls)
    }

    func stopPrefetch(at indexes: [Int]) {
        let urls = indexes.map { items[$0].url }
        prefetcher.stopPrefetching(with: urls)
    }

    func didRequestDataUpdate() {
        fetchTrendingList()
    }

    func didSelectItem(at index: Int) {
        if let item = response?.data[index] {
            actions.showDetails(item)
        }
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
                self.response = response
                self.onListChange?()
            }
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

// MARK: Locale

private typealias Locale = String

private extension Locale {
    static let trendingListTitle = "Trending 🔥"
    static let searchBarPlaceholder = "Search GIPHY"
}
