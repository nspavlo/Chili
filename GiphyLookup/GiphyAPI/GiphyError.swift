//
//  GiphyError.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 20/11/2022.
//

import Foundation

// MARK: Initialization

public enum GiphyError: Error {
    public enum MapperError: Error {
        case response(statusCode: Int)
        case decoding(underlayingError: Error)
    }

    case parsing(underlayingError: MapperError)
    case network(underlayingError: Error)
}

// MARK: LocalizedError

extension GiphyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parsing(underlayingError: let underlayingError):
            return underlayingError.localizedDescription
        case .network(underlayingError: let underlayingError):
            return underlayingError.localizedDescription
        }
    }
}
