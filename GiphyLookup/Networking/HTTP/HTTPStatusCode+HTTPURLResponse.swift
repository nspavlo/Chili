//
//  HTTPStatusCode+HTTPURLResponse.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Foundation

public extension HTTPStatusCode {
    init?(_ response: HTTPURLResponse) {
        self.init(response.statusCode)
    }

    init?(_ rawValue: Int) {
        guard let value = HTTPStatusCode(rawValue: rawValue) else {
            return nil
        }

        self = value
    }
}
