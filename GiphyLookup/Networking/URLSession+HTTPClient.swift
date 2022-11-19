//
//  URLSession+HTTPClient.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Foundation

extension URLSession: HTTPClient {
    private struct URLSessionUnexpectedValueError: Error {}
    private struct URLSessionDataTaskWrapper: HTTPClientTask {
        let underlayingSessionDataTask: URLSessionDataTask

        func cancel() {
            underlayingSessionDataTask.cancel()
        }
    }

    /// - Parameter completion:
    /// The completion handler to call when the insert request is complete.
    /// This  handler is executed on the background queue.
    public func fetch(from url: URL, completion: @escaping CompletionHandler) -> HTTPClientTask {
        let task = dataTask(with: url) { data, response, error in
            if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(URLSessionUnexpectedValueError()))
            }
        }
        task.resume()
        return URLSessionDataTaskWrapper(underlayingSessionDataTask: task)
    }
}
