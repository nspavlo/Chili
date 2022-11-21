//
//  GiphyResponse.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

// MARK: Initialization

public struct GiphyResponse {
    public let data: [GIF]
    public let pagination: Pagination
}

// MARK: Decodable

extension GiphyResponse: Decodable {
    enum CodingKeys: CodingKey {
        case data
        case pagination
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lossyDataElementWrapper = try container.decode(LossyArray<GIF>.self, forKey: .data)
        data = lossyDataElementWrapper.wrappedValue
        pagination = try container.decode(Pagination.self, forKey: .pagination)
    }
}
