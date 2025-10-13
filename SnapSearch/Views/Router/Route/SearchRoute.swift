//
//  SearchRoute.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

// MARK: - SearchRoute

enum SearchRoute: Sendable {
    case photoDetail(Photo)
}

extension SearchRoute: Hashable {
    
    static func == (lhs: SearchRoute, rhs: SearchRoute) -> Bool {
        switch (lhs, rhs) {
        case (.photoDetail(let lhsPhoto), .photoDetail(let rhsPhoto)):
            return lhsPhoto.id == rhsPhoto.id
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .photoDetail(let photo):
            hasher.combine(photo.id)
        }
    }
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
