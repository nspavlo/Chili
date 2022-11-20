//
//  GiphyListController.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation
import GiphyLookup

// MARK: -

// MARK: Initialization

final class GiphyListController: GiphyListViewModelOutput {
    let searchBarPlaceholder = "Search GIPHY"
    var onStateChange: ((GiphyListViewModelState) -> Void)?

    private let repository: GiphyFetchable
    private var cancellable: Cancellable?

    init(repository: GiphyFetchable) {
        self.repository = repository
    }
}

// MARK: GiphyListViewModelInput

extension GiphyListController: GiphyListViewModelInput {
    func viewDidLoad() {
        onStateChange?(.loading)

        cancellable = repository
            .fetchTrendingList()
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
