//
//  GiphySearchViewModel.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 21/11/2022.
//

// MARK: Input

protocol GiphySearchViewModelInput {
    var title: String { get }
    var searchBarPlaceholder: String { get }

    func updateSearchQuery(_ query: String?)
    func dismissSearchQuery()
}

typealias GiphySearchViewModel = GiphySearchViewModelInput
