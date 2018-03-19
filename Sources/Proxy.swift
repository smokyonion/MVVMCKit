//
//  Proxy.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import Foundation

/// A proxy which hosts proxy extensions of `Base`.
public struct InputProxy<Base> {
    /// The `Base` instance the extensions would be invoked with.
    public let base: Base
    
    /// Construct a proxy
    ///
    /// - parameters:
    ///   - base: The object to be proxied.
    init(_ base: Base) {
        self.base = base
    }
}

/// A proxy which hosts proxy extensions of `Base`.
public struct OutputProxy<Base> {
    /// The `Base` instance the extensions would be invoked with.
    public let base: Base
    
    /// Construct a proxy
    ///
    /// - parameters:
    ///   - base: The object to be proxied.
    init(_ base: Base) {
        self.base = base
    }
}

/// Describes a provider of InputProxy extensions.
///
/// - note: `InputExtensionProvider` does not indicate whether a type is
///         input. It is intended for extensions to types that are not owned
///         by the module in order to avoid name collisions and return type
///         ambiguities.
public protocol InputExtensionProvider: class {}

extension InputExtensionProvider {
    /// A proxy which hosts input extensions for `self`.
    public var input: InputProxy<Self> {
        return InputProxy(self)
    }
    
    /// A proxy which hosts static input extensions for the type of `self`.
    public static var input: InputProxy<Self>.Type {
        return InputProxy<Self>.self
    }
}

/// Describes a provider of OutputProxy extensions.
///
/// - note: `OutputExtensionProvider` does not indicate whether a type is
///         output. It is intended for extensions to types that are not owned
///         by the module in order to avoid name collisions and return type
///         ambiguities.
public protocol OutputExtensionProvider: class {}

extension OutputExtensionProvider {
    /// A proxy which hosts output extensions for `self`.
    public var output: InputProxy<Self> {
        return InputProxy(self)
    }
    
    /// A proxy which hosts static output extensions for the type of `self`.
    public static var output: InputProxy<Self>.Type {
        return InputProxy<Self>.self
    }
}
