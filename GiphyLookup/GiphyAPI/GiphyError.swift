//
//  GiphyError.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

public enum GiphyError: Error {
    public enum MapperError: Error {
        case response(statusCode: Int)
        case decoding(underlayingError: Error)
    }

    case parsing(underlayingError: MapperError)
    case network(underlayingError: Error)
}
