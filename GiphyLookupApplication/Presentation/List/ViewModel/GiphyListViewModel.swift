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
}

// MARK: ViewModel Output

enum GiphyListViewModelState {
    case loading
    case result(Result<GiphyListItemViewModels, Error>)
}

protocol GiphyListViewModelOutput: AnyObject {
    var searchBarPlaceholder: String { get }
    var onStateChange: ((GiphyListViewModelState) -> Void)? { get set }
}

typealias GiphyListViewModel = GiphyListViewModelInput & GiphyListViewModelOutput
