//
//  APIRequestClient.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/08
//  

import Foundation

// MARK: - APIRequestProviding

protocol APIRequestProviding: Sendable {
    
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}

// MARK: - APIRequestClient

struct APIRequestClient {
    
    let configuration: APIConfiguration
    let session: URLSession
    let decoder: JSONDecoder
    
    init(configuration: APIConfiguration) {
        self.configuration = configuration
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        sessionConfig.httpAdditionalHeaders = [
            "Authorization": configuration.apiKey
        ]
        
        self.session = URLSession(configuration: sessionConfig)
        self.decoder = JSONDecoder()
    }
}

extension APIRequestClient {
    
    static func create(apiKey: String, baseURL: String) -> Self {
        
        let configuration = APIConfiguration(
            baseURL: baseURL,
            apiKey: apiKey,
            timeout: 30
        )
        
        return APIRequestClient(configuration: configuration)
    }
}

// MARK: - extension for implements APIProviding

extension APIRequestClient: APIRequestProviding {
    
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        
        guard let url = endpoint.url(baseURL: configuration.baseURL) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            logger.debug(.network, "endpoint: \(endpoint), response: \(response)")
            
            try handleResponse(response)
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.warn(.network, "decode error. endpoint: \(endpoint), error: \(error)")
                throw APIError.decodingError(error.localizedDescription)
            }
        } catch let error as APIError {
            throw error
        } catch {
            logger.warn(.network, "request error. endpoint: \(endpoint), error: \(error)")
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - private method

private extension APIRequestClient {
    
    func handleResponse(_ response: URLResponse) throws {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimitExceeded
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unknown
        }
    }
}
