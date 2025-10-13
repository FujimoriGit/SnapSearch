//
//  CacheStorage.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/14
//

import Foundation

// MARK: - CacheStorageManaging

protocol CacheStorageManaging: Sendable {
    func getData(for key: String) async -> Data?
    func store(_ data: Data, for key: String) async
    func remove(for key: String) async
    func removeAll() async
    func contains(key: String) async -> Bool
    func updateAccessOrder(for key: String) async
}

// MARK: - CacheStorage

actor CacheStorage {
    private var storage: [String: Data] = [:]
    private var accessOrder: [String] = []
    private let maxItems: Int
    private let maxMemoryBytes: Int
    private var currentMemoryUsage: Int = 0
    
    init(maxItems: Int = 100, maxMemoryMB: Int = 50) {
        self.maxItems = maxItems
        self.maxMemoryBytes = maxMemoryMB * 1024 * 1024
    }
}

// MARK: - extension for implements CacheStorageManaging

extension CacheStorage: CacheStorageManaging {
    func getData(for key: String) -> Data? {
        return storage[key]
    }
    
    func store(_ data: Data, for key: String) {
        // メモリチェックと削除
        ensureMemoryLimit(additionalBytes: data.count)
        
        if let existingData = storage[key] {
            currentMemoryUsage -= existingData.count
        }
        storage[key] = data
        currentMemoryUsage += data.count
        
        updateAccessOrder(for: key)
        
        ensureItemLimit()
    }
    
    func remove(for key: String) {
        if let data = storage.removeValue(forKey: key) {
            currentMemoryUsage -= data.count
            accessOrder.removeAll { $0 == key }
        }
    }
    
    func removeAll() {
        storage.removeAll()
        accessOrder.removeAll()
        currentMemoryUsage = 0
    }
    
    func contains(key: String) -> Bool {
        return storage[key] != nil
    }
    
    func updateAccessOrder(for key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }
}

// MARK: - private methods

private extension CacheStorage {
    
    func ensureMemoryLimit(additionalBytes: Int) {
        while currentMemoryUsage + additionalBytes > maxMemoryBytes && !storage.isEmpty {
            evictOldest()
        }
    }
    
    func ensureItemLimit() {
        while storage.count > maxItems {
            evictOldest()
        }
    }
    
    func evictOldest() {
        guard let oldestKey = accessOrder.first else { return }
        remove(for: oldestKey)
    }
}
