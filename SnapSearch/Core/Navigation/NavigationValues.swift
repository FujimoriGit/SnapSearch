//
//  NavigationRouter.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import SwiftUI

// MARK: - NavigationKey

protocol NavigationKey {
    associatedtype Value: Sendable
    static var liveValue: Value { get }
}

// MARK: - NavigationValues

struct NavigationValues: Sendable {

    @TaskLocal fileprivate static var current = Self()
    private var storage: [ObjectIdentifier: Sendable] = [:]

    // swiftlint:disable:next unneeded_synthesized_initializer
    private init() {}

    subscript<K>(key: K.Type) -> K.Value where K: NavigationKey {
        
        get {
            
            guard let base = storage[ObjectIdentifier(key)] as? K.Value else {
                
                return key.liveValue
            }
            return base
        }
        
        set {
            
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

extension NavigationValues {
    
    static func scoped<K: NavigationKey, R>(
        _ key: K.Type,
        to value: K.Value,
        operation: () -> R
    ) -> R {
        var snap = NavigationValues.current
        snap[key] = value
        return NavigationValues.$current.withValue(snap) { operation() }
    }
    
    static func scoped<K: NavigationKey, R>(
        _ key: K.Type,
        to value: K.Value,
        operation: () async -> R
    ) async -> R {
        var snap = NavigationValues.current
        snap[key] = value
        return await NavigationValues.$current.withValue(snap) { await operation() }
    }
    
    /// 指定KeyPathに対応する値を差し替え、指定したViewのサブツリーにだけ適用します
    static func scoped<Value, Content: View>(
        _ keyPath: WritableKeyPath<NavigationValues, Value>,
        to value: Value,
        @ViewBuilder content: () -> Content
    ) -> some View {
        var snap = NavigationValues.current
        snap[keyPath: keyPath] = value
        return NavigationValues.$current.withValue(snap) { content() }
    }
}

// MARK: - NavigationRoot

/// 指定Keyに Routerを注入し、このサブツリーにだけ有効化するView
struct NavigationRoot<R: Hashable & Sendable, Content: View>: View {
    
    private let keyPath: WritableKeyPath<NavigationValues, Router<R>>
    @State private var router: Router<R>
    private let content: () -> Content

    init(_ keyPath: WritableKeyPath<NavigationValues, Router<R>>,
         @ViewBuilder content: @escaping () -> Content) {
        self.keyPath = keyPath
        router = NavigationValues.current[keyPath: keyPath]
        self.content = content
    }

    var body: some View {
        NavigationValues.scoped(keyPath, to: router) {
            NavigationStack(path: $router.path) {
                content()
            }
        }
    }
}

// MARK: - propertyWrapper

@propertyWrapper
struct Navigation<Value> {
    
    private let keyPath: KeyPath<NavigationValues, Value> & Sendable

    init(_ keyPath: KeyPath<NavigationValues, Value> & Sendable) {
        
        self.keyPath = keyPath
    }

    var wrappedValue: Value { NavigationValues.current[keyPath: keyPath] }
}
