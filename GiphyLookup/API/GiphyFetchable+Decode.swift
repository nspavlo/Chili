//
//  GiphyFetchable+Decode.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Combine
import Foundation

func decode<T: Decodable>(_ data: Data, response _: URLResponse) -> AnyPublisher<T, GiphyError> {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError(GiphyError.MapperError.decoding)
        .mapError(GiphyError.parsing)
        .eraseToAnyPublisher()
}
