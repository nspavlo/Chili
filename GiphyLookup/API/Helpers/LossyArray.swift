//
//  LossyArray.swift
//  GiphyLookup
//
//  Created by Jans Pavlovs on 21/11/2022.
//

// MARK: Initialization

struct LossyArray<T: Decodable> {
    var wrappedValue: [T]

    init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: Decodable

extension LossyArray: Decodable {
    private struct AnyDecodable: Decodable {}

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [T] = []

        while !container.isAtEnd {
            do {
                let wrapper = try container.decode(T.self)
                elements.append(wrapper)
            } catch {
                _ = try? container.decode(AnyDecodable.self)
            }
        }

        wrappedValue = elements
    }
}
