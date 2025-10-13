//
//  SearchRoute.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

// MARK: - SearchRoute

enum SearchRoute: Hashable, Sendable, CaseIterable {
    case photoDetail
}

// MARK: - NavigationValues injection

private enum SearchRouterKey: NavigationKey {
    static let liveValue: Router<SearchRoute> = Router()
}

extension NavigationValues {
    var search: Router<SearchRoute> {
        get { self[SearchRouterKey.self] }
        set { self[SearchRouterKey.self] = newValue }
    }
}
