//
//  URLSessionHTTPClientTests.swift
//  GiphyLookupTests
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import GiphyLookup
import XCTest

// MARK: XCTestCase

final class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.clean()
        super.tearDown()
    }
}

// MARK: Request

extension URLSessionHTTPClientTests {
    func test_request_whenExecuted_shouldExecuteUsingProvidedURL() throws {
        let url: URL = .anyURL()
        let sut = makeSystemComponentsUnderTest()
        let request = try request(for: sut, url: url)

        XCTAssertEqual(request.url, url)
    }

    func test_request_whenExecuted_shouldExecuteUsingMethodGET() throws {
        let sut = makeSystemComponentsUnderTest()
        let request = try request(for: sut, url: .anyURL())

        XCTAssertEqual(request.httpMethod, "GET")
    }

    func request(
        for sut: HTTPClient,
        url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URLRequest {
        let expectation = expectation(description: "Wait for `\(sut)` to execute request.")
        var capturedRequest: URLRequest?
        URLProtocolStub.observeRequests { request in
            capturedRequest = request
            expectation.fulfill()
        }
        sut.fetch(from: url, completion: { _ in })
        wait(for: [expectation], timeout: 0.5)
        return try XCTUnwrap(capturedRequest, file: file, line: line)
    }
}

// MARK: Request Cancelation

extension URLSessionHTTPClientTests {
    func test_request_whenCanceled_shouldCancelRequestAndReturnAppropriateErrorCode() throws {
        let receivedError = try resultError(for: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }

    private func resultError(
        for taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Error? {
        let result = try result(for: nil, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
}

// MARK: Request Failure

extension URLSessionHTTPClientTests {
    typealias ResponseValues = URLProtocolStub.Values

    func test_request_withoutNetworkConnection_shouldDeliverConnectivityError() throws {
        let expectedError: NSError = .anyNetworkConnectionLostError()
        let values = ResponseValues(data: nil, response: nil, error: expectedError)
        let receivedError = try resultError(for: values) as NSError?

        XCTAssertEqual(receivedError?.code, expectedError.code)
    }

    func test_request_withoutAnyDataAndAnyErrorAndAnyResponse_shouldDeliverError() throws {
        let values = ResponseValues(data: nil, response: nil, error: nil)
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyUnexpectedResponse_shouldDeliverError() throws {
        let values = ResponseValues(data: nil, response: .anyURLResponse(), error: nil)
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyUnexpectedResponseAndAnyError_shouldDeliverError() throws {
        let values = ResponseValues(data: nil, response: .anyURLResponse(), error: .anyError())
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyUnexpectedResponseAndAnyData_shouldDeliverError() throws {
        let values = ResponseValues(data: .anyData(), response: .anyURLResponse(), error: nil)
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyUnexpectedResponseAndAnyDataAndAnyError_shouldDeliverError() throws {
        let values = ResponseValues(data: .anyData(), response: .anyURLResponse(), error: .anyError())
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyData_shouldDeliverError() throws {
        let values = ResponseValues(data: .anyData(), response: nil, error: nil)
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyDataAndAnyError_shouldDeliverError() throws {
        let values = ResponseValues(data: .anyData(), response: nil, error: .anyError())
        XCTAssertNotNil(try resultError(for: values))
    }

    func test_request_withAnyExpectedResponseAndAnyError_shouldDeliverError() throws {
        let values = ResponseValues(data: nil, response: makeAnyHTTPURLResponse(), error: .anyError())
        XCTAssertNotNil(try resultError(for: values))
    }

    private func resultError(
        for values: ResponseValues?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Error? {
        let result = try result(for: values, file: file, line: line)
        switch result {
        case .success:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        case let .failure(error):
            return error
        }
    }
}

// MARK: Success

extension URLSessionHTTPClientTests {
    func test_request_withAnyExpectedResponseAndAnyData_shouldDeliverData() throws {
        let data: Data = .anyData()
        let result = try resultValues(for: .init(data: data, response: makeAnyHTTPURLResponse(), error: nil))

        XCTAssertEqual(result?.data, data)
    }

    func test_request_withAnyExpectedResponseAndAnyData_shouldDeliverResponseStatusCode() throws {
        let response = makeAnyHTTPURLResponse()
        let result = try resultValues(for: .init(data: .anyData(), response: response, error: nil))

        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }

    func test_request_withAnyExpectedResponseAndAnyData_shouldDeliverResponseURL() throws {
        let response = makeAnyHTTPURLResponse()
        let result = try resultValues(for: .init(data: .anyData(), response: response, error: nil))

        XCTAssertEqual(result?.response.url, response.url)
    }

    func test_request_withAnyExpectedResponse_shouldDeliverEmptyData() throws {
        let response = makeAnyHTTPURLResponse()
        let result = try resultValues(for: .init(data: nil, response: response, error: nil))

        XCTAssertEqual(result?.data, Data())
    }

    private func resultValues(
        for values: URLProtocolStub.Values?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (data: Data?, response: HTTPURLResponse)? {
        let result = try result(for: values, file: file, line: line)
        switch result {
        case let .success(value):
            return value
        case .failure:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
}

// MARK: Shared Expectations

private extension URLSessionHTTPClientTests {
    func result(
        for values: URLProtocolStub.Values?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> HTTPClient.ClientResult {
        let sut = makeSystemComponentsUnderTest(file: file, line: line)
        URLProtocolStub.stub(with: values)

        var capturedResult: HTTPClient.ClientResult?
        let expectation = expectation(description: "Wait for `\(sut)` to load data.")
        taskHandler(sut.fetch(from: .anyURL()) { result in
            capturedResult = result
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.5)
        return try XCTUnwrap(capturedResult, file: file, line: line)
    }
}

// MARK: -

// MARK: Factory Methods

private extension URLSessionHTTPClientTests {
    func makeSystemComponentsUnderTest(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        trackForMemoryLeaks(configuration, file: file, line: line)

        let sut = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func makeAnyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(
            url: .anyURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
}

// MARK: -

// MARK: Helpers

extension URL {
    static func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
}

extension NSError {
    static func anyNetworkConnectionLostError() -> NSError {
        .init(domain: "a-domain", code: NSURLErrorNetworkConnectionLost)
    }

    static func anyError() -> NSError {
        anyNetworkConnectionLostError()
    }
}

extension Data {
    static func anyData() -> Data {
        "{\"entries\": []}".data(using: .utf8)!
    }
}

extension URLResponse {
    static func anyURLResponse() -> URLResponse {
        URLResponse(
            url: .anyURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
}
