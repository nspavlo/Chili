//
//  GiphyResponse.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

public struct GiphyResponse: Decodable {
    public struct GIF: Decodable {
        public struct Images: Decodable {
            public let preview: Preview
        }

        public let title: String
        public let images: Images
    }

    public struct Pagination: Decodable {
        let offset: Int
        let count: Int
    }

    public let data: [GIF]
    public let pagination: Pagination
}

public struct Preview {
    public let mp4: URL
    public let width: Int
    public let height: Int
}

extension Preview: Decodable {
    struct ConversionError: Error {}

    enum CodingKeys: String, CodingKey {
        case mp4
        case width
        case height
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        mp4 = try values.decode(URL.self, forKey: .mp4)
        if let value = Int(try values.decode(String.self, forKey: .width)) {
            width = value
        } else {
            throw ConversionError()
        }

        if let value = Int(try values.decode(String.self, forKey: .height)) {
            height = value
        } else {
            throw ConversionError()
        }
    }
}
