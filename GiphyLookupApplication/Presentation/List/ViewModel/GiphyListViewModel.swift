//
//  GiphyListViewModel.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

// MARK: ViewModel Input

protocol GiphyListViewModelInput {
    func viewDidLoad()
    func updateSearchQuery(_ query: String?)
    func dismissSearchQuery()
}

// MARK: ViewModel Output

enum GiphyListViewModelState {
    case loading
    case result(Result<GiphyListItemViewModels, Error>)
}

protocol GiphyListViewModelOutput: AnyObject {
    var title: String { get }
    var searchBarPlaceholder: String { get }
    var onStateChange: ((GiphyListViewModelState) -> Void)? { get set }
}

typealias GiphyListViewModel = GiphyListViewModelInput & GiphyListViewModelOutput
