//
//  GiphyListController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation
import GiphyLookup

// MARK: Initialization

final class GiphyListController: GiphyListViewModelOutput {
    let title: String = .trendingListTitle
    let searchBarPlaceholder: String = .searchBarPlaceholder
    var onStateChange: ((GiphyListViewModelState) -> Void)?

    private let repository: GiphyFetchable
    private var repositoryRequestCancellable: Cancellable?
    private var isSearchingActive = false

    private let currentQuerySubject = PassthroughSubject<String?, Never>()
    private var currentQuerySubjectCancelable: Cancellable?

    init(repository: GiphyFetchable) {
        self.repository = repository
    }
}

// MARK: GiphyListViewModelInput

extension GiphyListController: GiphyListViewModelInput {
    func viewDidLoad() {
        onStateChange?(.loading)
        fetchTrendingList()

        currentQuerySubjectCancelable = currentQuerySubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .sink { query in
                self.isSearchingActive = true
                self.onStateChange?(.loading)
                self.fetchList(query: query, page: 0)
            }
    }

    func searchQueryValueChanged(_ query: String?) {
        currentQuerySubject.send(query)
    }

    func dismissSearchQuery() {
        if isSearchingActive {
            isSearchingActive = false
            fetchTrendingList()
        }
    }
}

// MARK: Private Methods

private extension GiphyListController {
    func fetchTrendingList() {
        repositoryRequestCancellable = fetch(from: repository.fetchTrendingList())
    }

    func fetchList(query: String, page: Int) {
        repositoryRequestCancellable = fetch(from: repository.fetchList(query: query, page: page))
    }

    func fetch(from publisher: GiphyFetchable.Publisher) -> AnyCancellable {
        publisher
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.onStateChange?(.result(.failure(error)))
                }
            }
            receiveValue: { value in
                let items: GiphyListItemViewModels = value.data.map { data in
                    let preview = data.images.preview
                    return .init(title: data.title, width: preview.width, height: preview.height, url: preview.mp4)
                }
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
