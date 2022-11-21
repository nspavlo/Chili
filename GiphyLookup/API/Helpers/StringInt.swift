//
//  StringInt.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import Foundation

// MARK: Initialization

public struct StringInt: RawRepresentable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: Decodable

extension StringInt: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Int(stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid integer string.")
        }

        rawValue = value
    }
}
