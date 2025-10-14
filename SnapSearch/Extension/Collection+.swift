//
//  Collection+.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

extension Collection {
    
    subscript(safe index: Index) -> Element? {
        
        guard indices.contains(index) else {
            
            logger.error(.app, "index out of range. index: \(index), self: \(self)")
            return nil
        }
        return self[index]
    }
}
