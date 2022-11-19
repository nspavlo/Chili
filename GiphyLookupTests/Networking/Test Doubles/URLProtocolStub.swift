//
//  URLProtocolStub.swift
//  GiphyLookupTests
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import Foundation

// MARK: Initialization

final class URLProtocolStub: URLProtocol {
    struct Values {
        let data: Data?
        let response: URLResponse?
        let error: NSError?
    }

    private static var stubs: Values?
    private static var requestObserver: ((URLRequest) -> Void)?

    static func stub(with values: Values?) {
        stubs = values
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    static func clean() {
        stubs = nil
        requestObserver = nil
    }

    // MARK: Abstract methods

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    // MARK: Loading

    override func startLoading() {
        guard let client else {
            fatalError("Can't stub requests without client")
        }

        if let requestObserver = URLProtocolStub.requestObserver {
            client.urlProtocolDidFinishLoading(self)
            return requestObserver(request)
        } else {
            let stub = URLProtocolStub.stubs

            if let data = stub?.data {
                client.urlProtocol(self, didLoad: data)
            }

            if let response = stub?.response {
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub?.error {
                client.urlProtocol(self, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(self)
            }
        }
    }

    override func stopLoading() {}
}
