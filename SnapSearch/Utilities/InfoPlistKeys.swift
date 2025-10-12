//
//  InfoPlistKeys.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/10
//  

import Foundation

enum InfoPlistKeys: String {
    
    case pexelsAPIKey = "PexelsAPIKey"
}

extension InfoPlistKeys {
    
    func getValue<T>() -> T? {
        
        Bundle.main.object(forInfoDictionaryKey: rawValue) as? T
    }
}
