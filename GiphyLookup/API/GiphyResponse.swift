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

// MARK: -

// MARK: Initialization

struct LossyArray<T: Decodable> {
    var wrappedValue: [T]

    init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: Decodable

extension LossyArray: Decodable {
    private struct AnyDecodable: Decodable {}

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [T] = []

        while !container.isAtEnd {
            do {
                let wrapper = try container.decode(T.self)
                elements.append(wrapper)
            } catch {
                _ = try? container.decode(AnyDecodable.self)
            }
        }

        wrappedValue = elements
    }
}

// MARK: -

public struct GIF: Decodable {
    public struct Images: Decodable {
        public let fixed_width: Preview
    }

    public let title: String
    public let images: Images
}

public struct Pagination: Decodable {
    let offset: Int
    let count: Int
}


public struct Preview {
    public let url: URL
    public let width: Int
    public let height: Int
}

extension Preview: Decodable {
    struct ConversionError: Error {}

    enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        url = try values.decode(URL.self, forKey: .url)
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
