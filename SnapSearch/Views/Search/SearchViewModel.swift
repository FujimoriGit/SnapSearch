//
//  SearchViewModel.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Observation

// MARK: - SearchViewState

struct SearchViewState: Equatable, Sendable {
    var searchText = ""
    var photos: [Photo] = []
    var isLoading = false
    var isLoadingAdditionalPhotos = false
    var errorMessage: String?
    var hasMorePages = true
}

// MARK: - SearchViewModel

@MainActor
@Observable
final class SearchViewModel {
    
    // MARK: - public property
    
    private(set) var state = SearchViewState()
    
    // MARK: - private properties

    @ObservationIgnored
    @Dependency(\.pexelsAPIProvider) private var pexelsAPIProvider
    
    @ObservationIgnored
    @Dependency(\.imageLoadingProvider) private var imageLoader
    
    @ObservationIgnored
    @Navigation(\.search) private var router
    
    private var currentPage = 1
    private var currentQuery = ""
    private var searchTask: Task<Void, Never>?
}

// MARK: - public methods

extension SearchViewModel {
    
    func onSubmitSearchText() {
        let query = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            loadInitialPhotos()
            return
        }
        
        // 同じクエリの場合は検索しない
        guard query != currentQuery else { return }
        
        currentQuery = query
        searchTask?.cancel()
        
        searchTask = Task {
            await performSearch(resetResults: true)
        }
    }
    
    func onAppearThumbnail(photo: Photo) {
        // 最後から3番目のアイテムが表示されたら追加読み込み
        guard photo.id == state.photos[safe: state.photos.count - 3]?.id,
              !state.isLoadingAdditionalPhotos,
              !state.isLoading,
              state.hasMorePages,
              !currentQuery.isEmpty else { return }
        
        Task {
            await performSearch(resetResults: false)
        }
    }
    
    func tappedThumbnail(photo: Photo) {
        
        router.push(.photoDetail(photo))
    }
    
    func enteredSearchText(_ text: String) {
        state.searchText = text
    }
    
    func tappedClearButton() {
        searchTask?.cancel()
        state.searchText = ""
        state.photos = []
        currentPage = 1
        currentQuery = ""
        state.hasMorePages = true
        state.errorMessage = nil
    }
    
    func tappedRecommendPhotoButton() {
        loadInitialPhotos()
    }
}

// MARK: - private methods

private extension SearchViewModel {

    func performSearch(resetResults: Bool) async {
        if resetResults {
            state.isLoading = true
            state.photos = []
            currentPage = 1
            state.hasMorePages = true
            state.errorMessage = nil
        } else {
            state.isLoadingAdditionalPhotos = true
        }
        
        do {
            let response = try await pexelsAPIProvider.searchPhotos(
                query: currentQuery,
                page: currentPage,
                perPage: 20
            )
            
            if Task.isCancelled { return }
            
            if resetResults {
                state.photos = response.photos
            } else {
                state.photos.append(contentsOf: response.photos)
            }
            
            state.hasMorePages = response.nextPage != nil
            currentPage += 1
            state.errorMessage = nil
            
            // プリロード画像
            let urls = response.photos.prefix(10).map { $0.src.medium }
            await imageLoader.preloadImages(urls: Array(urls))
            
        } catch {
            if !Task.isCancelled {
                state.errorMessage = error.localizedDescription
            }
        }
        
        state.isLoading = false
        state.isLoadingAdditionalPhotos = false
    }
    
    func loadInitialPhotos() {
        guard state.photos.isEmpty else { return }
        
        Task {
            await loadCuratedPhotos()
        }
    }
    
    func loadCuratedPhotos() async {
        state.isLoading = true
        state.errorMessage = nil
        
        do {
            let response = try await pexelsAPIProvider.getCuratedPhotos(page: 1, perPage: 20)
            state.photos = response.photos
            state.hasMorePages = response.nextPage != nil
            
            let urls = response.photos.prefix(10).map { $0.src.medium }
            await imageLoader.preloadImages(urls: Array(urls))
            
        } catch {
            state.errorMessage = error.localizedDescription
        }
        
        state.isLoading = false
    }
}
