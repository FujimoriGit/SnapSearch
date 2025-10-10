//
//  PexelsAPIParam.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/08
//  

// MARK: - SearchResponse

struct SearchResponse: Codable {
    let totalResults: Int
    let page: Int
    let perPage: Int
    let photos: [Photo]
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
        case photos
        case nextPage = "next_page"
    }
}

// MARK: - Photo

struct Photo: Codable, Identifiable, Equatable, Sendable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerURL: String
    let photographerID: Int
    let avgColor: String?
    let src: PhotoSource
    let liked: Bool
    let alt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case url
        case photographer
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
        case src
        case liked
        case alt
    }
}

// MARK: - PhotoSource

struct PhotoSource: Codable, Equatable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
    
    enum CodingKeys: String, CodingKey {
        case original
        case large2x
        case large
        case medium
        case small
        case portrait
        case landscape
        case tiny
    }
}
