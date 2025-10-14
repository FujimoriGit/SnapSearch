//
//  SearchViewModelTests.swift
//  SnapSearch
//
//  Created by Daiki Fujimori on 2025/10/15
//

@testable import SnapSearch
import Testing

// MARK: - SearchViewModelClearButtonTests

@Suite("SearchViewModel クリアボタンテスト")
@MainActor
struct SearchViewModelClearButtonTests {
    
    @Test("tappedClearButtonが_呼び出された時_全ての状態が初期化される")
    func tappedClearButtonが_呼び出された時_全ての状態が初期化される() async {
        // Given: SearchViewModelを初期化して各種データを設定
        let viewModel = SearchViewModel()
        viewModel.enteredSearchText("nature")
        
        // When: tappedClearButtonを呼び出した時
        viewModel.tappedClearButton()
        
        // Then: 全ての状態が初期化される
        #expect(viewModel.state == SearchViewState())
    }
}

// MARK: - SearchViewModelSearchTests

@Suite("SearchViewModel 検索機能テスト")
@MainActor
struct SearchViewModelSearchTests {
    
    @Test
    func onSubmitSearchTextが_有効なクエリで実行された時_PexelsAPIProviderのsearchPhotosが呼ばれる() async {
        // Given: モックAPIプロバイダーと成功レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = [createMockPhoto(id: 1, photographer: "Test")]
        let mockResponse = SearchResponse(totalResults: 1, page: 1, perPage: 20, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.searchPhotosResult = .success(mockResponse)

        // When: 依存関係を注入してViewModelを初期化し、onSubmitSearchTextを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("ocean")
            viewModel.onSubmitSearchText()
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: mockPexelsAPIのsearchPhotosが1回呼ばれる
            #expect(mockPexelsAPI.searchPhotosCallCount == 1)
            #expect(mockPexelsAPI.lastSearchQuery == "ocean")
            #expect(mockPexelsAPI.lastSearchPage == 1)
            #expect(mockPexelsAPI.lastSearchPerPage == 20)
        }
    }
    
    @Test
    func onSubmitSearchTextが_空文字列で実行された時_getCuratedPhotosが呼ばれる() async {
        // Given: モックAPIプロバイダーと成功レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = [createMockPhoto(id: 1, photographer: "Test")]
        let mockResponse = SearchResponse(totalResults: 1, page: 1, perPage: 20, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.getCuratedPhotosResult = .success(mockResponse)

        // When: 依存関係を注入してViewModelを初期化し、onSubmitSearchTextを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("")
            viewModel.onSubmitSearchText()
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: mockPexelsAPIのgetCuratedPhotosが1回呼ばれる
            #expect(mockPexelsAPI.getCuratedPhotosCallCount == 1)
            #expect(mockPexelsAPI.lastCuratedPage == 1)
            #expect(mockPexelsAPI.lastCuratedPerPage == 20)
        }
    }
    
    @Test
    func onSubmitSearchTextが_空白のみのクエリで実行された時_getCuratedPhotosが呼ばれる() async {
        // Given: モックAPIプロバイダーと成功レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = [createMockPhoto(id: 1, photographer: "Test")]
        let mockResponse = SearchResponse(totalResults: 1, page: 1, perPage: 20, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.getCuratedPhotosResult = .success(mockResponse)

        // When: 依存関係を注入してViewModelを初期化し、onSubmitSearchTextを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("   ")
            viewModel.onSubmitSearchText()
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: mockPexelsAPIのgetCuratedPhotosが1回呼ばれる
            #expect(mockPexelsAPI.getCuratedPhotosCallCount == 1)
        }
    }
    
    @Test
    func onSubmitSearchTextが_同じクエリで2回実行された時_APIは1回だけ呼ばれる() async {
        // Given: モックAPIプロバイダーと成功レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = [createMockPhoto(id: 1, photographer: "Test")]
        let mockResponse = SearchResponse(totalResults: 1, page: 1, perPage: 20, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.searchPhotosResult = .success(mockResponse)

        // When: 依存関係を注入してViewModelを初期化し、同じクエリでonSubmitSearchTextを2回実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("nature")
            viewModel.onSubmitSearchText()
            try? await Task.sleep(nanoseconds: 200_000_000)
            viewModel.onSubmitSearchText()
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: mockPexelsAPIのsearchPhotosが1回だけ呼ばれる
            #expect(mockPexelsAPI.searchPhotosCallCount == 1)
        }
    }
}

// MARK: - SearchViewModelRecommendTests

@Suite("SearchViewModel おすすめ写真テスト")
@MainActor
struct SearchViewModelRecommendTests {
    
    @Test
    func tappedRecommendPhotoButtonが_写真が空の状態で呼ばれた時_getCuratedPhotosが呼ばれる() async {
        // Given: モックAPIプロバイダーと成功レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = [createMockPhoto(id: 1, photographer: "Test")]
        let mockResponse = SearchResponse(totalResults: 1, page: 1, perPage: 20, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.getCuratedPhotosResult = .success(mockResponse)

        // When: 依存関係を注入してViewModelを初期化し、tappedRecommendPhotoButtonを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.tappedRecommendPhotoButton()
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: mockPexelsAPIのgetCuratedPhotosが1回呼ばれる
            #expect(mockPexelsAPI.getCuratedPhotosCallCount == 1)
        }
    }
}

// MARK: - SearchViewModelErrorTests

@Suite("SearchViewModel APIエラーテスト")
@MainActor
struct SearchViewModelErrorTests {
    
    @Test
    func onSubmitSearchTextが_APIエラーが発生した時_errorMessageが設定される() async {
        // Given: モックAPIプロバイダーにエラーレスポンスを設定
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        mockPexelsAPI.searchPhotosResult = .failure(APIError.unauthorized)

        // When: 依存関係を注入してViewModelを初期化し、onSubmitSearchTextを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("test")
            viewModel.onSubmitSearchText()
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: errorMessageが設定される
            #expect(viewModel.state.errorMessage != nil)
            #expect(viewModel.state.isLoading == false)
            #expect(viewModel.state.photos.isEmpty)
        }
    }
    
    @Test
    func tappedRecommendPhotoButtonが_APIエラーが発生した時_errorMessageが設定される() async {
        // Given: モックAPIプロバイダーにエラーレスポンスを設定
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        mockPexelsAPI.getCuratedPhotosResult = .failure(APIError.networkError("Network error"))

        // When: 依存関係を注入してViewModelを初期化し、tappedRecommendPhotoButtonを実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.tappedRecommendPhotoButton()
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: errorMessageが設定される
            #expect(viewModel.state.errorMessage != nil)
            #expect(viewModel.state.isLoading == false)
            #expect(viewModel.state.photos.isEmpty)
        }
    }
}

// MARK: - SearchViewModelPaginationTests

@Suite("SearchViewModel ページネーションテスト")
@MainActor
struct SearchViewModelPaginationTests {
    
    @Test
    func onAppearThumbnailが_最後から3番目の写真で呼ばれた時_追加のsearchPhotosが呼ばれる() async {
        // Given: モックAPIプロバイダーと10枚の写真を持つ初回レスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = (1...10).map { createMockPhoto(id: $0, photographer: "Test \($0)") }
        let initialResponse = SearchResponse(totalResults: 20, page: 1, perPage: 10, photos: mockPhotos, nextPage: "next_page_url")
        mockPexelsAPI.searchPhotosResult = .success(initialResponse)

        // When: 依存関係を注入してViewModelを初期化し、初回検索を実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("nature")
            viewModel.onSubmitSearchText()
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // 2回目のAPI呼び出し用のレスポンスを設定
            let additionalPhotos = (11...20).map { createMockPhoto(id: $0, photographer: "Test \($0)") }
            let additionalResponse = SearchResponse(totalResults: 20, page: 2, perPage: 10, photos: additionalPhotos, nextPage: nil)
            mockPexelsAPI.searchPhotosResult = .success(additionalResponse)
            
            // When: 最後から3番目の写真でonAppearThumbnailを呼び出した時
            let targetPhoto = mockPhotos[7] // 10枚中の8番目（最後から3番目）
            viewModel.onAppearThumbnail(photo: targetPhoto)
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: searchPhotosが2回呼ばれる（初回 + 追加読み込み）
            #expect(mockPexelsAPI.searchPhotosCallCount == 2)
            #expect(viewModel.state.photos.count >= 10) // 初回の写真は確実に存在
            #expect(viewModel.state.isLoadingAdditionalPhotos == false)
        }
    }
    
    @Test
    func onAppearThumbnailが_最後のページで呼ばれた時_APIは呼ばない() async {
        // Given: モックAPIプロバイダーとnextPageがnilの最終ページレスポンスを準備
        let mockPexelsAPI = MockPexelsAPIProvider()
        let mockImageLoader = MockImageLoader()
        let mockPhotos = (1...10).map { createMockPhoto(id: $0, photographer: "Test \($0)") }
        let finalResponse = SearchResponse(totalResults: 10, page: 1, perPage: 10, photos: mockPhotos, nextPage: nil)
        mockPexelsAPI.searchPhotosResult = .success(finalResponse)

        // When: 依存関係を注入してViewModelを初期化し、初回検索を実行した時
        await DependencyValues.withDependency {
            $0.pexelsAPIProvider = mockPexelsAPI
            $0.imageLoadingProvider = mockImageLoader
        } operation: {
            let viewModel = SearchViewModel()
            viewModel.enteredSearchText("nature")
            viewModel.onSubmitSearchText()
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // callCountをリセット
            let initialCallCount = mockPexelsAPI.searchPhotosCallCount
            
            // When: 最後から3番目の写真でonAppearThumbnailを呼び出した時（hasMorePages = false）
            let targetPhoto = mockPhotos[7] // 10枚中の8番目（最後から3番目）
            viewModel.onAppearThumbnail(photo: targetPhoto)
            
            // 非同期処理の完了を待つ
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Then: 追加のAPI呼び出しは発生しない
            #expect(mockPexelsAPI.searchPhotosCallCount == initialCallCount)
            #expect(viewModel.state.hasMorePages == false)
        }
    }
}

// MARK: - Helper functions

private func createMockPhoto(id: Int, photographer: String) -> Photo {
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
    
    return Photo(
        id: id,
        width: 800,
        height: 600,
        url: "https://example.com",
        photographer: photographer,
        photographerURL: "https://example.com/photographer",
        photographerID: 1,
        avgColor: "#FFFFFF",
        src: mockPhotoSource,
        liked: false,
        alt: "Test photo"
    )
}
