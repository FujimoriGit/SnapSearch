//
//  PexelsAPIClientTests.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/12
//  

@testable import SnapSearch
import Testing

// MARK: - APIRequestClientInitTests

@Suite
struct APIRequestClientInitTests {
    
    @Test
    func APIRequestClientが_APIキーとbaseURLを渡して生成する時_指定した値でconfigurationが設定される() {
        // Given: APIキー"test-api-key"とbaseURL"https://api.example.com"を準備
        let apiKey = "test-api-key"
        let baseURL = "https://api.example.com"
        
        // When: createメソッドでクライアントを生成した時
        let client = APIRequestClient.create(apiKey: apiKey, baseURL: baseURL)
        
        // Then: configurationに指定したAPIキーとbaseURLとタイムアウト30秒が設定される
        #expect(client.configuration.apiKey == apiKey)
        #expect(client.configuration.baseURL == baseURL)
        #expect(client.configuration.timeout == 30)
    }
}

// MARK: - PexelsAPIClientSearchTests

@Suite("PexelsAPIClient searchPhotosテスト")
struct PexelsAPIClientSearchTests {
    
    @Test("searchPhotosが_有効なクエリを渡した時_APIRequestProviderのfetchが1回呼ばれる")
    func searchPhotosが_有効なクエリを渡した時_APIRequestProviderのfetchが1回呼ばれる() async throws {
        // Given: モックプロバイダーと成功レスポンスを準備
        let mockProvider = MockAPIRequestProvider()
        let mockResponse = SearchResponse(totalResults: 0, page: 1, perPage: 10, photos: [], nextPage: nil)
        mockProvider.fetchResult = .success(mockResponse)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: query="ocean"でsearchPhotosを呼び出した時
        _ = try await client.searchPhotos(query: "ocean", page: 1, perPage: 10)
        
        // Then: モックプロバイダーのfetchメソッドが1回呼ばれる
        #expect(mockProvider.fetchCallCount == 1)
    }
    
    @Test("searchPhotosが_空文字列のクエリを渡した時_invalidURLエラーがスローされる")
    func searchPhotosが_空文字列のクエリを渡した時_invalidURLエラーがスローされる() async {
        // Given: モックプロバイダーと空文字列""を準備
        let mockProvider = MockAPIRequestProvider()
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: 空文字列でsearchPhotosを呼び出した時
        // Then: APIError.invalidURLがスローされる
        await #expect(throws: APIError.invalidURL) {
            try await client.searchPhotos(query: "", page: 1, perPage: 10)
        }
    }
    
    @Test("searchPhotosが_空白のみのクエリを渡した時_invalidURLエラーがスローされる")
    func searchPhotosが_空白のみのクエリを渡した時_invalidURLエラーがスローされる() async {
        // Given: モックプロバイダーと空白のみの"   "を準備
        let mockProvider = MockAPIRequestProvider()
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: 空白のみのクエリでsearchPhotosを呼び出した時
        // Then: APIError.invalidURLがスローされる
        await #expect(throws: APIError.invalidURL) {
            try await client.searchPhotos(query: "   ", page: 1, perPage: 10)
        }
    }
    
    @Test("searchPhotosが_page2とperPage20を指定した時_searchエンドポイントに同じ値が渡される")
    func searchPhotosが_page2とperPage20を指定した時_searchエンドポイントに同じ値が渡される() async throws {
        // Given: モックプロバイダーとpage=2、perPage=20を準備
        let mockProvider = MockAPIRequestProvider()
        let mockResponse = SearchResponse(totalResults: 0, page: 2, perPage: 20, photos: [], nextPage: nil)
        mockProvider.fetchResult = .success(mockResponse)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: query="forest"、page=2、perPage=20でsearchPhotosを呼び出した時
        _ = try await client.searchPhotos(query: "forest", page: 2, perPage: 20)
        
        // Then: エンドポイントにquery="forest"、page=2、perPage=20が渡される
        guard case .search(let query, let page, let perPage) = mockProvider.lastEndpoint else {
            Issue.record("エンドポイントがsearchではありません")
            return
        }
        #expect(query == "forest")
        #expect(page == 2)
        #expect(perPage == 20)
    }
}

// MARK: - PexelsAPIClientCuratedTests

@Suite
struct PexelsAPIClientCuratedTests {
    
    @Test("getCuratedPhotosが_page1とperPage15を指定した時_curatedエンドポイントに同じ値が渡される")
    func getCuratedPhotosが_page1とperPage15を指定した時_curatedエンドポイントに同じ値が渡される() async throws {
        // Given: モックプロバイダーとpage=1、perPage=15を準備
        let mockProvider = MockAPIRequestProvider()
        let mockResponse = SearchResponse(totalResults: 0, page: 1, perPage: 15, photos: [], nextPage: nil)
        mockProvider.fetchResult = .success(mockResponse)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: page=1、perPage=15でgetCuratedPhotosを呼び出した時
        _ = try await client.getCuratedPhotos(page: 1, perPage: 15)
        
        // Then: エンドポイントにpage=1、perPage=15が渡される
        guard case .curated(let page, let perPage) = mockProvider.lastEndpoint else {
            Issue.record("エンドポイントがcuratedではありません")
            return
        }
        #expect(page == 1)
        #expect(perPage == 15)
    }
    
    @Test("getCuratedPhotosが_呼び出された時_APIRequestProviderのfetchが1回呼ばれる")
    func getCuratedPhotosが_呼び出された時_APIRequestProviderのfetchが1回呼ばれる() async throws {
        // Given: モックプロバイダーと成功レスポンスを準備
        let mockProvider = MockAPIRequestProvider()
        let mockResponse = SearchResponse(totalResults: 0, page: 1, perPage: 10, photos: [], nextPage: nil)
        mockProvider.fetchResult = .success(mockResponse)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: getCuratedPhotosを呼び出した時
        _ = try await client.getCuratedPhotos(page: 1, perPage: 10)
        
        // Then: モックプロバイダーのfetchメソッドが1回呼ばれる
        #expect(mockProvider.fetchCallCount == 1)
    }
}

// MARK: - PexelsAPIClientPhotoTests

@Suite
struct PexelsAPIClientPhotoTests {
    
    @Test("getPhotoが_ID123を指定した時_photoエンドポイントにID123が渡される")
    func getPhotoが_ID123を指定した時_photoエンドポイントにID123が渡される() async throws {
        // Given: モックプロバイダーとID=123のPhotoレスポンスを準備
        let mockProvider = MockAPIRequestProvider()
        let mockPhotoSource = PhotoSource(
            original: "https://example.com/original.jpg",
            large2x: "https://example.com/large2x.jpg",
            large: "https://example.com/large.jpg",
            medium: "https://example.com/medium.jpg",
            small: "https://example.com/small.jpg",
            portrait: "https://example.com/portrait.jpg",
            landscape: "https://example.com/landscape.jpg",
            tiny: "https://example.com/tiny.jpg"
        )
        let mockPhoto = Photo(
            id: 123,
            width: 800,
            height: 600,
            url: "https://example.com",
            photographer: "Test Photographer",
            photographerURL: "https://example.com/photographer",
            photographerID: 1,
            avgColor: "#FFFFFF",
            src: mockPhotoSource,
            liked: false,
            alt: "Test photo"
        )
        mockProvider.fetchResult = .success(mockPhoto)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: ID=123でgetPhotoを呼び出した時
        _ = try await client.getPhoto(id: 123)
        
        // Then: エンドポイントにID=123が渡される
        guard case .photo(let id) = mockProvider.lastEndpoint else {
            Issue.record("エンドポイントがphotoではありません")
            return
        }
        #expect(id == 123)
    }
    
    @Test("getPhotoが_APIがエラーを返す時_エラーがそのままスローされる")
    func getPhotoが_APIがエラーを返す時_エラーがそのままスローされる() async {
        // Given: モックプロバイダーにunauthorizedエラーを設定
        let mockProvider = MockAPIRequestProvider()
        mockProvider.fetchResult = .failure(APIError.unauthorized)
        let client = PexelsAPIClient(apiRequestProvider: mockProvider)
        
        // When: getPhotoを呼び出した時
        // Then: APIError.unauthorizedがスローされる
        await #expect(throws: APIError.unauthorized) {
            try await client.getPhoto(id: 999)
        }
    }
}
