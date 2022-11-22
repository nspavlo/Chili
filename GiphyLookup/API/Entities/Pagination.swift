//
//  Pagination.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

// MARK: Initialization

public struct Pagination {
    public let count: UInt
    public let offset: UInt
    public let totalCount: UInt
}

// MARK: Decodable

extension Pagination: Decodable {}
