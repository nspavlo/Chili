//
//  GiphyListViewModelActions.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 22/11/2022.
//

import GiphyLookup

final class GiphyListViewModelActions {
    let showDetails: (GIF) -> Void
    let showError: (Error) -> Void

    init(showDetails: @escaping (GIF) -> Void, showError: @escaping (Error) -> Void) {
        self.showDetails = showDetails
        self.showError = showError
    }
}
