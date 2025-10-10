//
//  APIConfiguration.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/08
//  

import Foundation

// MARK: - APIConfiguration

struct APIConfiguration {
    let baseURL: String
    let apiKey: String
    let timeout: TimeInterval
}

// MARK: - APIError

enum APIError: LocalizedError, Sendable {
    case invalidURL
    case noData
    case decodingError(String)
    case networkError(String)
    case unauthorized
    case rateLimitExceeded
    case serverError(Int)
    case unknown
}
