//
//  Router.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Foundation

/// ViewModelからUI遷移を発火する構造体
@MainActor
@Observable
final class Router<R: Hashable & Sendable> {
    
    var path: [R] = []
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
