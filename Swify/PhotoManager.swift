import SwiftUI
import Photos
import PhotosUI

class PhotoManager: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var filteredPhotos: [PHAsset] = []
    @Published var hasPermission = false
    @Published var isLoading = false
    @Published var currentIndex = 0
    
    private var sortMode: SortMode = .chronological
    private let imageManager = PHCachingImageManager()
    
    init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            hasPermission = true
            loadPhotos()
        case .denied, .restricted:
            hasPermission = false
        case .notDetermined:
            hasPermission = false
        @unknown default:
            hasPermission = false
        }
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.hasPermission = true
                    self?.loadPhotos()
                case .denied, .restricted:
                    self?.hasPermission = false
                case .notDetermined:
                    self?.hasPermission = false
                @unknown default:
                    self?.hasPermission = false
                }
            }
        }
    }
    
    private func loadPhotos() {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        
        // Sortierung nach Aufnahmedatum (neueste zuerst)
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var photoArray: [PHAsset] = []
        allPhotos.enumerateObjects { asset, _, _ in
            photoArray.append(asset)
        }
        
        DispatchQueue.main.async {
            self.photos = photoArray
            self.applySortMode()
            self.isLoading = false
        }
    }
    
    func setSortMode(_ mode: SortMode) {
        sortMode = mode
        applySortMode()
    }
    
    private func applySortMode() {
        switch sortMode {
        case .random:
            filteredPhotos = photos.shuffled()
        case .chronological:
            filteredPhotos = photos.sorted { $0.creationDate ?? Date.distantPast > $1.creationDate ?? Date.distantPast }
        case .favoritesOnly:
            filteredPhotos = photos.filter { $0.isFavorite }
        }
        
        // Reset current index when sorting changes
        currentIndex = 0
    }
    
    func deletePhoto(_ asset: PHAsset, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Remove from local arrays
                    self.photos.removeAll { $0.localIdentifier == asset.localIdentifier }
                    self.filteredPhotos.removeAll { $0.localIdentifier == asset.localIdentifier }
                    
                    // Adjust current index if necessary
                    if self.currentIndex >= self.filteredPhotos.count && self.currentIndex > 0 {
                        self.currentIndex = self.filteredPhotos.count - 1
                    }
                }
                completion(success)
            }
        }
    }
    
    func toggleFavorite(_ asset: PHAsset, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !asset.isFavorite
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Update local cache
                    self.loadPhotos()
                }
                completion(success)
            }
        }
    }
    
    func loadImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func preloadImages(around index: Int) {
        let range = max(0, index - 2)...min(filteredPhotos.count - 1, index + 2)
        let targetSize = CGSize(width: 1000, height: 1000)
        
        for i in range {
            if i < filteredPhotos.count {
                let asset = filteredPhotos[i]
                imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil
                ) { _, _ in }
            }
        }
    }
}
