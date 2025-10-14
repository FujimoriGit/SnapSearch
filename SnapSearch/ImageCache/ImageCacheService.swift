//
//  ImageCacheService.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Foundation

// MARK: - ImageCaching

protocol ImageCaching: Sendable {
    func getCachedImage(for url: String) async -> Data?
    func cacheImage(_ data: Data, for url: String) async
}

// MARK: - ImageCacheService

actor ImageCacheService {
    private let storage: CacheStorageManaging
    
    init(storage: CacheStorageManaging = CacheStorage()) {
        self.storage = storage
    }
}

// MARK: - extension for implements ImageCaching

extension ImageCacheService: ImageCaching {
    func getCachedImage(for url: String) async -> Data? {
        let data = await storage.getData(for: url)
        if data != nil {
            await storage.updateAccessOrder(for: url)
        }
        return data
    }
    
    func cacheImage(_ data: Data, for url: String) async {
        await storage.store(data, for: url)
    }
}
