//
//  ImageLoadingClient.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Foundation

// MARK: - ImageLoading

protocol ImageLoading: Sendable {
    func loadImage(from urlString: String) async throws -> Data
    func preloadImages(urls: [String]) async
}

// MARK: - ImageLoadingClient

actor ImageLoadingClient {
    private let cacheService: ImageCaching
    private let session: URLSession
    
    init(cacheService: ImageCaching = ImageCacheService()) {
        self.cacheService = cacheService
        
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024,
            diskPath: "image_cache"
        )
        
        self.session = URLSession(configuration: configuration)
    }
}

// MARK: - extension for implements ImageLoading

extension ImageLoadingClient: ImageLoading {
    
    func loadImage(from urlString: String) async throws -> Data {
        
        if let cachedData = await cacheService.getCachedImage(for: urlString) {
            return cachedData
        }
        
        let data = try await fetchImage(from: urlString)
        await cacheService.cacheImage(data, for: urlString)
        
        return data
    }
    
    func preloadImages(urls: [String]) async {
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls.prefix(5) {
                group.addTask { [weak self] in
                    _ = try? await self?.loadImage(from: url)
                }
            }
        }
    }
}

// MARK: - private method

private extension ImageLoadingClient {
    
    func fetchImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            logger.error(.network, "Invalid URL: \(urlString)")
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error(.network, "Invalid response type")
                throw APIError.unknown
            }
            
            guard httpResponse.statusCode == 200 else {
                logger.error(.network, "HTTP Error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            return data
        } catch {
            logger.error(.network, "Network error: \(error)")
            throw error
        }
    }
}

// MARK: - DependencyValues injection

private enum ImageLoadingProviderKey: DependencyKey {
    static let liveValue: ImageLoading = ImageLoadingClient()
}

extension DependencyValues {
    
    var imageLoadingProvider: ImageLoading {
        get { self[ImageLoadingProviderKey.self] }
        set { self[ImageLoadingProviderKey.self] = newValue }
    }
}
