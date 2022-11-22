//
//  GiphyResponseTests.swift
//  GiphyLookupTests
//
//  Created by Jans Pavlovs on 21/11/2022.
//

import GiphyLookup
import XCTest

// MARK: XCTestCase

final class GiphyResponseTests: XCTestCase {
    func test_decodingArray_whenOneElementIsInvalid_shouldReturnArrayWithoutInvalidElement() throws {
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: "PartlyInvalidImages", withExtension: "json") else {
            XCTFail("Missing file: PartlyInvalidImages.json")
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(GiphyResponse.self, from: try Data(contentsOf: url, options: .alwaysMapped))

        XCTAssertEqual(response.data.count, 4)
    }
}
