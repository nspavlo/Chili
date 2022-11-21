//
//  GiphyListController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation
import GiphyLookup

// MARK: Actions

final class GiphyListViewModelActions {
    let showGiphyDetails: (GIF) -> Void

    init(showGiphyDetails: @escaping (GIF) -> Void) {
        self.showGiphyDetails = showGiphyDetails
    }
}

// MARK: Initialization

final class GiphyListController: GiphyListViewModelOutput {
    let title: String = .trendingListTitle
    let searchBarPlaceholder: String = .searchBarPlaceholder
    var onStateChange: ((GiphyListViewModelState) -> Void)?

    private let giphyFetcher: GiphyFetchable
    private var giphyFetcherCancellable: Cancellable?
    private let actions: GiphyListViewModelActions
    private var response: GiphyResponse?
    private var isSearchingActive = false

    private let currentQuerySubject = PassthroughSubject<SearchQuery, Never>()
    private var currentQuerySubjectCancelable: Cancellable?

    init(giphyFetcher: GiphyFetchable, actions: GiphyListViewModelActions) {
        self.giphyFetcher = giphyFetcher
        self.actions = actions
    }
}

// MARK: GiphyListViewModelInput

extension GiphyListController: GiphyListViewModelInput {
    func onAppear() {
        onStateChange?(.loading)
        fetchTrendingList()

        currentQuerySubjectCancelable = currentQuerySubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { query in
                self.isSearchingActive = true
                self.onStateChange?(.loading)
                self.fetchList(query: query)
            }
    }

    func updateSearchQuery(_ query: String?) {
        guard let searchQuery = SearchQuery(query) else {
            return
        }

        currentQuerySubject.send(searchQuery)
    }

    func dismissSearchQuery() {
        if isSearchingActive {
            isSearchingActive = false
            fetchTrendingList()
        }
    }

    func didSelectItem(at index: Int) {
        if let item = response?.data[index] {
            actions.showGiphyDetails(item)
        }
    }

    func didLoadNextPage() {}
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
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.onStateChange?(.result(.failure(error)))
                }
            }
            receiveValue: { response in
                let items: GiphyListItemViewModels = response.data.map { data in
                    let preview = data.images.fixedWidth
                    return .init(
                        title: data.title,
                        width: preview.width.rawValue,
                        height: preview.height.rawValue,
                        url: preview.url
                    )
                }
                self.response = response
                self.onStateChange?(.result(.success(items)))
            }
    }
}

// MARK: Locale

private typealias Locale = String

private extension Locale {
    static let trendingListTitle = "Trending 🔥"
    static let searchBarPlaceholder = "Search GIPHY"
}
