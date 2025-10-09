//
//  APIEndpoint.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/08
//  

import Foundation

// MARK: - APIEndpoint

enum APIEndpoint: Sendable {
    
    case search(query: String, page: Int, perPage: Int)
    case curated(page: Int, perPage: Int)
    case photo(id: Int)
    
    func url(baseURL: String) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }
}

// MARK: - extension for path

extension APIEndpoint {
    
    var path: String {
        switch self {
        case .search:
            return "/search"
        case .curated:
            return "/curated"
        case .photo(let id):
            return "/photos/\(id)"
        }
    }
}

// MARK: - extension for queryItems

extension APIEndpoint {
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let query, let page, let perPage):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .curated(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .photo:
            return []
        }
    }
}
