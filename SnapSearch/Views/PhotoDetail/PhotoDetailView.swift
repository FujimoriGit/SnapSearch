//
//  PhotoDetailView.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/14
//  

import SwiftUI

struct PhotoDetailView: View {
    
    @State private var viewModel: PhotoDetailViewModel
    
    init(photo: Photo) {
        viewModel = PhotoDetailViewModel(photo: photo)
    }
    
    private var toolbarVisibility: Visibility {
        viewModel.state.isNavigationHidden ? .hidden : .visible
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                photoContent(viewModel.state, parentSize: geometry.size)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.state.photo.photographer)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                shareButton(photo: viewModel.state.photo)
            }
        }
        .toolbar(toolbarVisibility, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.onAppear()
        }
    }
}

private extension PhotoDetailView {
    
    @ViewBuilder
    func photoContent(_ state: PhotoDetailViewState, parentSize: CGSize) -> some View {
        
        if let imageData = state.imageData,
           let uiImage = UIImage(data: imageData) {
            
            imageView(uiImage, state: state, parentSize: parentSize)
        } else if state.isLoadingImage {
            
            VStack(spacing: 16) {
                ProgressView()
                Text("画像を読み込み中...")
                    .foregroundStyle(.white.opacity(0.8))
            }
        } else if let error = state.imageLoadError {
            
            errorView(error)
        }
    }
    
    func imageView(_ uiImage: UIImage, state: PhotoDetailViewState, parentSize: CGSize) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: parentSize.width)
            .scaleEffect(state.scale)
            .offset(state.offset)
            .animation(.spring(), value: state.scale)
            .animation(.spring(), value: state.offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        viewModel.onMagnificationGestureChanged(value)
                    }
                    .onEnded { _ in
                        viewModel.onMagnificationGestureEnded()
                    }
                    .simultaneously(with: DragGesture()
                        .onChanged { value in
                            viewModel.onDragGestureChanged(value.translation)
                        }
                        .onEnded { _ in
                            viewModel.onDragGestureEnded()
                        }
                    )
            )
            .onTapGesture(count: 1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.onSingleTapped()
                }
            }
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    viewModel.onDoubleTapped()
                }
            }
    }
    
    func shareButton(photo: Photo) -> some View {
        Menu {
            Button {
                viewModel.tappedMenuButton(photo.url)
            } label: {
                Label("Pexelsで開く", systemImage: "globe")
            }
            
            Button {
                viewModel.tappedMenuButton(photo.photographerURL)
            } label: {
                Label("フォトグラファーのページ", systemImage: "person.circle")
            }
            
            if let imageData = viewModel.state.imageData,
               let uiImage = UIImage(data: imageData) {
                ShareLink(
                    item: Image(uiImage: uiImage),
                    preview: SharePreview(
                        photo.alt ?? "Photo",
                        image: Image(uiImage: uiImage)
                    )
                ) {
                    Label("画像を共有", systemImage: "square.and.arrow.up")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("画像の読み込みに失敗しました")
                .foregroundStyle(.white)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("再試行") {
                viewModel.tappedRetryButton()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
