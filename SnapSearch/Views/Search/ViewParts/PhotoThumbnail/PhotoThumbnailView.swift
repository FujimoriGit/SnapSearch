//
//  PhotoThumbnailView.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import SwiftUI

struct PhotoThumbnailView: View {
    
    @State private var viewModel: PhotoThumbnailViewModel
    
    init(photo: Photo) {
        
        self.viewModel = PhotoThumbnailViewModel(photo: photo)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 画像表示
                if let imageData = viewModel.state.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width
                        )
                        .clipped()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.state.imageData)
                }
                
                // ローディング表示
                if viewModel.state.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                // エラー表示
                if viewModel.state.loadError {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.white)
                        .font(.caption)
                }
                
                // フォトグラファー名
                photographerOverlay
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .task {
            await viewModel.onAppear()
        }
    }
    
    private var photographerOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Text(viewModel.state.photo.photographer)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    )
                Spacer()
            }
            .padding(6)
        }
    }
}
