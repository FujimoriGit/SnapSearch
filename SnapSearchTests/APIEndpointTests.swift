//
//  APIEndpointTests.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/12
//  

@testable import SnapSearch
import Testing

// MARK: - APIEndpointURLTests

@Suite
struct APIEndpointURLTests {
    
    @Test
    func searchエンドポイントが_queryとpageとperPageを渡した時_全てのパラメータを含むURLが生成される() {
        // Given: searchエンドポイントにquery="nature"、page=2、perPage=20を設定
        let endpoint = APIEndpoint.search(query: "nature", page: 2, perPage: 20)
        let baseURL = "https://api.pexels.com/v1"
        
        // When: baseURLを使ってURLを生成した時
        let url = endpoint.url(baseURL: baseURL)
        
        // Then: URLが生成され、/searchパスと3つのクエリパラメータが全て含まれる
        #expect(url != nil)
        #expect(url?.absoluteString.contains("/search") ?? false)
        #expect(url?.absoluteString.contains("query=nature") ?? false)
        #expect(url?.absoluteString.contains("page=2") ?? false)
        #expect(url?.absoluteString.contains("per_page=20") ?? false)
    }
    
    @Test
    func curatedエンドポイントが_pageとperPageを渡した時_2つのパラメータを含むURLが生成される() {
        // Given: curatedエンドポイントにpage=3、perPage=15を設定
        let endpoint = APIEndpoint.curated(page: 3, perPage: 15)
        let baseURL = "https://api.pexels.com/v1"
        
        // When: baseURLを使ってURLを生成した時
        let url = endpoint.url(baseURL: baseURL)
        
        // Then: URLが生成され、/curatedパスとpageとper_pageパラメータが含まれ、queryパラメータは含まれない
        #expect(url != nil)
        #expect(url?.absoluteString.contains("/curated") ?? false)
        #expect(url?.absoluteString.contains("page=3") ?? false)
        #expect(url?.absoluteString.contains("per_page=15") ?? false)
        #expect(!(url?.absoluteString.contains("query=") ?? false))
    }
    
    @Test
    func photoエンドポイントが_IDを渡した時_IDを含むパスが生成される() {
        // Given: photoエンドポイントにID=12345を設定
        let photoID = 12345
        let endpoint = APIEndpoint.photo(id: photoID)
        let baseURL = "https://api.pexels.com/v1"
        
        // When: baseURLを使ってURLを生成した時
        let url = endpoint.url(baseURL: baseURL)
        
        // Then: /photos/12345というパスのURLが生成される
        #expect(url?.absoluteString == "https://api.pexels.com/v1/photos/12345")
    }
}

// MARK: - APIEndpointPathTests

@Suite
struct APIEndpointPathTests {
    
    @Test
    func searchエンドポイントが_pathを取得する時_searchが返される() {
        // Given: query="test"のsearchエンドポイントを作成
        let endpoint = APIEndpoint.search(query: "test", page: 1, perPage: 10)
        
        // When: pathプロパティを取得した時
        let path = endpoint.path
        
        // Then: "/search"という文字列が返される
        #expect(path == "/search")
    }
    
    @Test
    func curatedエンドポイントが_pathを取得する時_curatedが返される() {
        // Given: curatedエンドポイントを作成
        let endpoint = APIEndpoint.curated(page: 1, perPage: 10)
        
        // When: pathプロパティを取得した時
        let path = endpoint.path
        
        // Then: "/curated"という文字列が返される
        #expect(path == "/curated")
    }
    
    @Test
    func photoエンドポイントが_ID99を渡した時_photos99が返される() {
        // Given: ID=99のphotoエンドポイントを作成
        let endpoint = APIEndpoint.photo(id: 99)
        
        // When: pathプロパティを取得した時
        let path = endpoint.path
        
        // Then: "/photos/99"という文字列が返される
        #expect(path == "/photos/99")
    }
}
