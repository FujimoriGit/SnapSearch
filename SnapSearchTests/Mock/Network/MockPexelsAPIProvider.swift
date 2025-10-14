//
//  MockPexelsAPIProvider.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/15
//  

@testable import SnapSearch

final class MockPexelsAPIProvider: PexelsAPIProviding, @unchecked Sendable {
    /// searchPhotosメソッドの戻り値を設定するためのプロパティ
    var searchPhotosResult: Result<SearchResponse, Error>?
    /// searchPhotosメソッドが呼ばれた回数をカウント
    var searchPhotosCallCount = 0
    /// 最後に呼ばれたsearchPhotosメソッドのパラメータを保存
    var lastSearchQuery: String?
    var lastSearchPage: Int?
    var lastSearchPerPage: Int?
    
    /// getCuratedPhotosメソッドの戻り値を設定するためのプロパティ
    var getCuratedPhotosResult: Result<SearchResponse, Error>?
    /// getCuratedPhotosメソッドが呼ばれた回数をカウント
    var getCuratedPhotosCallCount = 0
    /// 最後に呼ばれたgetCuratedPhotosメソッドのパラメータを保存
    var lastCuratedPage: Int?
    var lastCuratedPerPage: Int?
    
    /// getPhotoメソッドの戻り値を設定するためのプロパティ
    var getPhotoResult: Result<Photo, Error>?
    /// getPhotoメソッドが呼ばれた回数をカウント
    var getPhotoCallCount = 0
    /// 最後に呼ばれたgetPhotoメソッドのIDを保存
    var lastPhotoId: Int?
    
    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> SearchResponse {
        searchPhotosCallCount += 1
        lastSearchQuery = query
        lastSearchPage = page
        lastSearchPerPage = perPage
        
        guard let result = searchPhotosResult else {
            throw APIError.unknown
        }
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func getCuratedPhotos(page: Int, perPage: Int) async throws -> SearchResponse {
        getCuratedPhotosCallCount += 1
        lastCuratedPage = page
        lastCuratedPerPage = perPage
        
        guard let result = getCuratedPhotosResult else {
            throw APIError.unknown
        }
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func getPhoto(id: Int) async throws -> Photo {
        getPhotoCallCount += 1
        lastPhotoId = id
        
        guard let result = getPhotoResult else {
            throw APIError.unknown
        }
        
        switch result {
        case .success(let photo):
            return photo
        case .failure(let error):
            throw error
        }
    }
}
