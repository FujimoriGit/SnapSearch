//
//  MockAPIRequestProvider.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/12
//  

@testable import SnapSearch

final class MockAPIRequestProvider: APIRequestProviding, @unchecked Sendable {
    /// fetchメソッドの戻り値を設定するためのプロパティ
    var fetchResult: Result<Any, Error>?
    /// fetchメソッドが呼ばれた回数をカウント
    var fetchCallCount = 0
    /// 最後に呼ばれたfetchメソッドのエンドポイントを保存
    var lastEndpoint: APIEndpoint?
    
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        fetchCallCount += 1
        lastEndpoint = endpoint
        
        guard let result = fetchResult else {
            throw APIError.unknown
        }
        
        switch result {
        case .success(let value):
            guard let typedValue = value as? T else {
                throw APIError.decodingError("型が一致しません")
            }
            return typedValue
        case .failure(let error):
            throw error
        }
    }
}
