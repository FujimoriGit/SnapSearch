//
//  PexelsAPIClient.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/08
//  

// MARK: - PexelsAPIProviding

protocol PexelsAPIProviding: Sendable {
    
    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> SearchResponse
    func getCuratedPhotos(page: Int, perPage: Int) async throws -> SearchResponse
    func getPhoto(id: Int) async throws -> Photo
}

// MARK: - PexelsAPIClient

struct PexelsAPIClient {
    
    let apiRequestProvider: APIRequestProviding
}

// MARK: - extension for PexelsAPIProviding

extension PexelsAPIClient: PexelsAPIProviding {
    
    func searchPhotos(
        query: String,
        page: Int = 1,
        perPage: Int
    ) async throws -> SearchResponse {
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            throw APIError.invalidURL
        }
        
        return try await apiRequestProvider.fetch(
            .search(query: trimmedQuery, page: page, perPage: perPage)
        )
    }
    
    func getCuratedPhotos(
        page: Int = 1,
        perPage: Int
    ) async throws -> SearchResponse {
        
        return try await apiRequestProvider.fetch(
            .curated(page: page, perPage: perPage)
        )
    }
    
    func getPhoto(id: Int) async throws -> Photo {
        
        try await apiRequestProvider.fetch(
            .photo(id: id)
        )
    }
}

// MARK: - DependencyValues injection

private enum PexelsAPIProvidingKey: DependencyKey {
    
    static let baseURL = "https://api.pexels.com/v1"
    
    static let pexelsKey: String = {
        
        guard let pexelsAPIKey: String = InfoPlistKeys.pexelsAPIKey.getValue(),
              !pexelsAPIKey.isEmpty else {
            
            fatalError("Missing Pexels API key.")
        }
        
        return pexelsAPIKey
    }()
    
    static let liveValue: PexelsAPIProviding = PexelsAPIClient(
        apiRequestProvider: APIRequestClient.create(apiKey: pexelsKey, baseURL: baseURL)
    )
}

extension DependencyValues {
    
    var pexelsAPIProvider: PexelsAPIProviding {
        
        get { self[PexelsAPIProvidingKey.self] }
        set { self[PexelsAPIProvidingKey.self] = newValue }
    }
}
