//
//  PhotoDetailViewModel.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/14
//  

import Foundation
import UIKit

// MARK: - PhotoDetailViewState

struct PhotoDetailViewState: Equatable, Sendable {
    let photo: Photo
    var imageData: Data?
    var isLoadingImage = false
    var imageLoadError: String?
    var isNavigationHidden = false
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
}

// MARK: - PhotoDetailViewModel

@MainActor
@Observable
final class PhotoDetailViewModel {
    
    // MARK: - public property
    
    private(set) var state: PhotoDetailViewState
    
    // MARK: - private properties
    
    @ObservationIgnored
    @Dependency(\.imageLoadingProvider) private var imageLoader
    
    private var lastScale: CGFloat = 1.0
    private var lastOffset: CGSize = .zero
    
    // MARK: - initialize
    
    init(photo: Photo) {
        self.state = PhotoDetailViewState(photo: photo)
    }
}

// MARK: - public method

extension PhotoDetailViewModel {
    
    func onAppear() async {
        await loadFullImage()
    }
    
    func onMagnificationGestureChanged(_ value: CGFloat) {
        let delta = value / lastScale
        lastScale = value
        state.scale *= delta
    }
    
    func onMagnificationGestureEnded() {
        lastScale = 1.0
        state.scale = min(max(state.scale, 1), 4)
    }
    
    func onDragGestureChanged(_ translation: CGSize) {
        state.offset = CGSize(
            width: lastOffset.width + translation.width,
            height: lastOffset.height + translation.height
        )
    }
    
    func onDragGestureEnded() {
        lastOffset = state.offset
        if state.scale <= 1 {
            state.offset = .zero
            lastOffset = .zero
        }
    }
    
    func onSingleTapped() {
        state.isNavigationHidden.toggle()
    }
    
    func onDoubleTapped() {
        if state.scale > 1 {
            state.scale = 1
            state.offset = .zero
            lastOffset = .zero
        } else {
            state.scale = 2
        }
    }
    
    func tappedRetryButton() {
        Task {
            await loadFullImage()
        }
    }
    
    func tappedMenuButton(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - private method

private extension PhotoDetailViewModel {
    
    func loadFullImage() async {
        guard state.imageData == nil else { return }
        
        state.isLoadingImage = true
        state.imageLoadError = nil
        
        do {
            let data = try await imageLoader.loadImage(
                from: state.photo.src.large2x
            )
            state.imageData = data
        } catch {
            state.imageLoadError = error.localizedDescription
        }
        
        state.isLoadingImage = false
    }
}
