//
//  MockImageLoader.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/15
//  

@testable import SnapSearch
import Foundation

final class MockImageLoader: ImageLoading, @unchecked Sendable {
    /// loadImageメソッドの戻り値を設定するためのプロパティ
    var loadImageResult: Result<Data, Error>?
    /// loadImageメソッドが呼ばれた回数をカウント
    var loadImageCallCount = 0
    /// 最後に呼ばれたloadImageメソッドのurlStringを保存
    var lastLoadImageURL: String?
    
    /// preloadImagesメソッドが呼ばれた回数をカウント
    var preloadImagesCallCount = 0
    /// 最後に呼ばれたpreloadImagesメソッドのurlsを保存
    var lastPreloadImageURLs: [String]?
    
    func loadImage(from urlString: String) async throws -> Data {
        loadImageCallCount += 1
        lastLoadImageURL = urlString
        
        guard let result = loadImageResult else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock result set"])
        }
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func preloadImages(urls: [String]) async {
        preloadImagesCallCount += 1
        lastPreloadImageURLs = urls
    }
}