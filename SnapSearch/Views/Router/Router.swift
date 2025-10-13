//
//  Router.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Foundation

// MARK: - Navigator

/// UIスタックの実体
@MainActor
@Observable
final class Navigator {
    /// 表示中ルートの履歴
    var path: [AnyHashable] = []
    
    nonisolated init() {}

    func push(_ route: AnyHashable) { path.append(route) }
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    func popToRoot() { path.removeAll(keepingCapacity: false) }
}

// MARK: - Router

/// ViewModelからUI遷移を発火する構造体
@MainActor
@Observable
final class Router<R: Hashable & Sendable>: Sendable {
    
    var path: [R] = [] {
        
        didSet{
            logger.debug(.view, "\(oldValue) -> \(self.path)")
        }
    }
    nonisolated init() {}
}

extension Router {
    
    func push(_ route: R) { path.append(route) }
    
    func pop() {
        
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() { path.removeAll(keepingCapacity: false) }
}
