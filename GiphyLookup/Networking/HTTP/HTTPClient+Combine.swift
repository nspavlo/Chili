//
//  HTTPClient+Combine.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Combine
import Foundation

public extension HTTPClient {
    func fetchPublisher(url: URL) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = fetch(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}
