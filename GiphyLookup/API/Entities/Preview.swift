//
//  Preview.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import Foundation

// MARK: Initialization

public struct Preview {
    public let url: URL
    public let width: StringInt
    public let height: StringInt
}

// MARK: Decodable

extension Preview: Decodable {}
