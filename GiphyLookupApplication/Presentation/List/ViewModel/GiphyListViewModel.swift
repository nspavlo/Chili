//
//  GiphyListViewModel.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

// MARK: Input

protocol GiphyListViewModelInput {
    func onAppear()
    func didRequestListUpdate()
    func didLoadNextPage()
    func didSelectItem(at index: Int)

    func startPrefetch(at indexes: [Int])
    func stopPrefetch(at indexes: [Int])
}

// MARK: Output

protocol GiphyListViewModelOutput: AnyObject {
    var onLoadingStateChange: ((Bool) -> Void)? { get set }
    var onListChange: (() -> Void)? { get set }

    var items: GiphyListItemViewModels { get }
}

typealias GiphyListViewModel = GiphyListViewModelInput & GiphyListViewModelOutput
