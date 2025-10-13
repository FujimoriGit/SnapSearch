//
//  SearchView.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import SwiftUI

struct SearchView: View {
    
    @Bindable private var viewModel = SearchViewModel()
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationRoot(\.search) {
            searchContent(viewModel.state)
                .navigationTitle("写真検索")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

private extension SearchView {
    
    @ViewBuilder
    func searchContent(_ state: SearchViewState) -> some View {
        VStack(spacing: 0) {
            // 検索フィールド
            searchField(state)
            
            // コンテンツ
            if state.isLoading && state.photos.isEmpty {
                loadingView()
            } else if let error = state.errorMessage, state.photos.isEmpty {
                errorView(error, state)
            } else if state.photos.isEmpty && !state.searchText.isEmpty {
                emptyView()
            } else if !state.photos.isEmpty {
                photoGrid(state)
            } else {
                initialView(state)
            }
        }
    }
    
    func searchField(_ state: SearchViewState) -> some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField(
                    "キーワードを入力",
                    text: Binding(
                        get: { state.searchText },
                        set: { viewModel.enteredSearchText($0) }
                    )
                )
                .textFieldStyle(.plain)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    viewModel.onSubmitSearchText()
                }
                .submitLabel(.search)
                
                if !state.searchText.isEmpty {
                    Button {
                        viewModel.tappedClearButton()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if !state.searchText.isEmpty {
                Button("検索") {
                    isSearchFieldFocused = false
                    viewModel.onSubmitSearchText()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func photoGrid(_ state: SearchViewState) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 120), spacing: 2)
                ],
                spacing: 2
            ) {
                ForEach(state.photos) { photo in
                    PhotoThumbnailView(photo: photo)
                        .onAppear {
                            viewModel.onAppearThumbnail(photo: photo)
                        }
                }
                
                // ローディングインジケータ
                if state.isLoadingAdditionalPhotos {
                    ProgressView()
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .gridCellColumns(3)
                }
            }
            .padding(.horizontal, 2)
        }
        .refreshable {
            if !state.searchText.isEmpty {
                viewModel.onSubmitSearchText()
            }
        }
    }
    
    func loadingView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("検索中...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func errorView(_ error: String, _ state: SearchViewState) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text("エラーが発生しました")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("再試行") {
                viewModel.onSubmitSearchText()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func emptyView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("検索結果がありません")
                .font(.headline)
            
            Text("別のキーワードで検索してください")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func initialView(_ state: SearchViewState) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("写真を検索")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("上の検索フィールドにキーワードを入力してください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("おすすめ写真を見る") {
                viewModel.tappedRecommendPhotoButton()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
}
