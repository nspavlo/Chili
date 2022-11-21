//
//  GiphySearchQuery.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

public struct GiphySearchQuery {
    let value: String

    public init?(_ string: String?) {
        guard let string, !string.isEmpty else {
            return nil
        }

        value = string
    }
}