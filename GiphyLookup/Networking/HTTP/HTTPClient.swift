//
//  HTTPClient.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias ClientResult = Result<(Data, HTTPURLResponse), Error>
    typealias CompletionHandler = (ClientResult) -> Void

    @discardableResult
    func fetch(from url: URL, completion: @escaping CompletionHandler) -> HTTPClientTask
}
