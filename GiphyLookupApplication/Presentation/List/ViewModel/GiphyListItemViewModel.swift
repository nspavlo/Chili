//
//  GiphyListItemViewModel.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Foundation

// MARK: Type Aliases

typealias GiphyListItemViewModels = [GiphyListItemViewModel]

// MARK: Initialization

struct GiphyListItemViewModel: Hashable {
    let title: String
    let width: Int
    let height: Int
    let url: URL
}
