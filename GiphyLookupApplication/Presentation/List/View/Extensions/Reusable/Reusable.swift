//
//  Reusable.swift
//  GiphyLookupApplication
//
//  Created by Jans Pavlovs on 19/11/2022.
//

// MARK: Initialization

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

// MARK: Default Implementation

extension Reusable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
