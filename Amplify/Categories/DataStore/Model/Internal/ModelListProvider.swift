//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Combine

/// - Warning: Although this has `public` access, it is intended for internal & codegen use and should not be used
/// directly by host applications. The behavior of this may change without warning. Though it is not used by host
/// application making any change to these `public` types should be backward compatible, otherwise it will be a breaking
/// change.
public protocol ModelListProvider {
    associatedtype Element: Model

    /// Retrieve the array of `Element` from the data source.
    func load() -> Result<[Element], CoreError>

    ///  Retrieve the array of `Element` from the data source asychronously.
    func load(completion: (Result<[Element], CoreError>) -> Void)

    /// Checks if there is subsequent data to retrieve. If True, the next page can be retrieved using.
    /// `getNextPage(completion)`
    func hasNextPage() -> Bool

    /// Retrieves the next page as a new in-memory List object asynchronously.
    func getNextPage(completion: (Result<List<Element>, CoreError>) -> Void)
}

/// - Warning: Although this has `public` access, it is intended for internal & codegen use and should not be used
/// directly by host applications. The behavior of this may change without warning. Though it is not used by host
/// application making any change to these `public` types should be backward compatible, otherwise it will be a breaking
/// change.
public struct AnyModelListProvider<Element: Model>: ModelListProvider {
    private let loadClosure: () -> Result<[Element], CoreError>
    private let loadWithCompletionClosure: ((Result<[Element], CoreError>) -> Void) -> Void
    private let hasNextPageClosure: () -> Bool
    private let getNextPageClosure: ((Result<List<Element>, CoreError>) -> Void) -> Void

    public init<Provider: ModelListProvider>(
        provider: Provider
    ) where Provider.Element == Self.Element {
        self.loadClosure = provider.load
        self.loadWithCompletionClosure = provider.load(completion:)
        self.hasNextPageClosure = provider.hasNextPage
        self.getNextPageClosure = provider.getNextPage(completion:)
    }

    public func load() -> Result<[Element], CoreError> {
        loadClosure()
    }

    public func load(completion: (Result<[Element], CoreError>) -> Void) {
        loadWithCompletionClosure(completion)
    }

    public func hasNextPage() -> Bool {
        hasNextPageClosure()
    }

    public func getNextPage(completion: (Result<List<Element>, CoreError>) -> Void) {
        getNextPageClosure(completion)
    }
}

/// - Warning: Although this has `public` access, it is intended for internal & codegen use and should not be used
/// directly by host applications. The behavior of this may change without warning. Though it is not used by host
/// application making any change to these `public` types should be backward compatible, otherwise it will be a breaking
/// change.
public extension ModelListProvider {
    func eraseToAnyModelListProvider() -> AnyModelListProvider<Element> {
        AnyModelListProvider(provider: self)
    }
}