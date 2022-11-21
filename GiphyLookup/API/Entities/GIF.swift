//
//  GIF.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

// MARK: Initialization

public struct GIF {
    public let title: String
    public let images: Images
}

// MARK: Decodable

extension GIF: Decodable {}
