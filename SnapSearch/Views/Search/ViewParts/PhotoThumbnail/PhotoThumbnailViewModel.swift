//
//  PhotoThumbnailViewModel.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/13
//  

import Foundation
import Observation

// MARK: - PhotoThumbnailViewState

struct PhotoThumbnailViewState: Equatable, Sendable {
    let photo: Photo
    var imageData: Data?
    var isLoading: Bool = true
    var loadError: Bool = false
}

// MARK: - PhotoThumbnailViewModel

@MainActor
@Observable
final class PhotoThumbnailViewModel {
    
    // MARK: - public property
    
    private(set) var state: PhotoThumbnailViewState
    
    // MARK: - private properties
    
    @ObservationIgnored
    @Dependency(\.imageLoadingProvider) private var imageLoader
    
    // MARK: - initialize
    
    init(photo: Photo) {
        self.state = PhotoThumbnailViewState(photo: photo)
    }
}

// MARK: - public methods

extension PhotoThumbnailViewModel {
    
    func onAppear() async {
        guard state.imageData == nil else { return }
        
        state.isLoading = true
        state.loadError = false
        
        do {
            let data = try await imageLoader.loadImage(
                from: state.photo.src.medium
            )
            state.imageData = data
            state.loadError = false
        } catch {
            logger.error(.network, "error: \(error)")
            state.loadError = true
        }
        
        state.isLoading = false
    }
}
