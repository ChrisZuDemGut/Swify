import SwiftUI
import Foundation

class ProgressManager: ObservableObject {
    @Published var reviewedPhotos: Set<String> = []
    @Published var photoActions: [String: PhotoReviewAction] = [:]
    @Published var lastReviewedIndex: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let reviewedPhotosKey = "SwifyReviewedPhotos"
    private let photoActionsKey = "SwifyPhotoActions"
    private let lastIndexKey = "SwifyLastIndex"
    
    init() {
        loadProgress()
    }
    
    func markAsReviewed(_ photoIdentifier: String, action: PhotoReviewAction) {
        reviewedPhotos.insert(photoIdentifier)
        photoActions[photoIdentifier] = action
        saveProgress()
    }
    
    func removeReview(_ photoIdentifier: String) {
        reviewedPhotos.remove(photoIdentifier)
        photoActions.removeValue(forKey: photoIdentifier)
        saveProgress()
    }
    
    func isReviewed(_ photoIdentifier: String) -> Bool {
        return reviewedPhotos.contains(photoIdentifier)
    }
    
    func getAction(for photoIdentifier: String) -> PhotoReviewAction? {
        return photoActions[photoIdentifier]
    }
    
    func updateLastReviewedIndex(_ index: Int) {
        lastReviewedIndex = index
        saveProgress()
    }
    
    func getProgress() -> (reviewed: Int, total: Int, percentage: Double) {
        let reviewed = reviewedPhotos.count
        let total = max(reviewed, 1) // Avoid division by zero
        let percentage = Double(reviewed) / Double(total) * 100
        return (reviewed, total, percentage)
    }
    
    func resetProgress() {
        reviewedPhotos.removeAll()
        photoActions.removeAll()
        lastReviewedIndex = 0
        saveProgress()
    }
    
    private func saveProgress() {
        // Save reviewed photos
        let reviewedArray = Array(reviewedPhotos)
        userDefaults.set(reviewedArray, forKey: reviewedPhotosKey)
        
        // Save photo actions
        let actionsData = photoActions.compactMapValues { action in
            return action.rawValue
        }
        userDefaults.set(actionsData, forKey: photoActionsKey)
        
        // Save last index
        userDefaults.set(lastReviewedIndex, forKey: lastIndexKey)
        
        userDefaults.synchronize()
        
        // If iCloud sync is available, sync to iCloud
        syncToiCloud()
    }
    
    private func loadProgress() {
        // Load reviewed photos
        if let reviewedArray = userDefaults.array(forKey: reviewedPhotosKey) as? [String] {
            reviewedPhotos = Set(reviewedArray)
        }
        
        // Load photo actions
        if let actionsData = userDefaults.dictionary(forKey: photoActionsKey) as? [String: String] {
            photoActions = actionsData.compactMapValues { actionString in
                return PhotoReviewAction(rawValue: actionString)
            }
        }
        
        // Load last index
        lastReviewedIndex = userDefaults.integer(forKey: lastIndexKey)
        
        // Try to load from iCloud
        loadFromiCloud()
    }
    
    private func syncToiCloud() {
        guard let ubiquityContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return // iCloud not available
        }
        
        let documentsPath = ubiquityContainer.appendingPathComponent("Documents")
        let progressFile = documentsPath.appendingPathComponent("swify_progress.json")
        
        do {
            try FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true)
            
            let progressData = ProgressData(
                reviewedPhotos: Array(reviewedPhotos),
                photoActions: photoActions.mapValues { $0.rawValue },
                lastReviewedIndex: lastReviewedIndex,
                lastUpdated: Date()
            )
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(progressData)
            
            try data.write(to: progressFile)
        } catch {
            print("Failed to sync to iCloud: \(error)")
        }
    }
    
    private func loadFromiCloud() {
        guard let ubiquityContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return // iCloud not available
        }
        
        let progressFile = ubiquityContainer
            .appendingPathComponent("Documents")
            .appendingPathComponent("swify_progress.json")
        
        do {
            let data = try Data(contentsOf: progressFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let progressData = try decoder.decode(ProgressData.self, from: data)
            
            // Check if iCloud data is newer than local data
            let localLastUpdate = userDefaults.object(forKey: "SwifyLastUpdate") as? Date ?? Date.distantPast
            
            if progressData.lastUpdated > localLastUpdate {
                // Use iCloud data
                reviewedPhotos = Set(progressData.reviewedPhotos)
                photoActions = progressData.photoActions.compactMapValues { PhotoReviewAction(rawValue: $0) }
                lastReviewedIndex = progressData.lastReviewedIndex
                
                userDefaults.set(progressData.lastUpdated, forKey: "SwifyLastUpdate")
                
                // Also save to local storage
                userDefaults.set(progressData.reviewedPhotos, forKey: reviewedPhotosKey)
                userDefaults.set(progressData.photoActions, forKey: photoActionsKey)
                userDefaults.set(progressData.lastReviewedIndex, forKey: lastIndexKey)
                userDefaults.synchronize()
            }
        } catch {
            print("Failed to load from iCloud: \(error)")
        }
    }
    
    func getStatistics() -> ProgressStatistics {
        let totalReviewed = reviewedPhotos.count
        let deletedCount = photoActions.values.filter { $0 == .delete }.count
        let keptCount = photoActions.values.filter { $0 == .keep }.count
        
        return ProgressStatistics(
            totalReviewed: totalReviewed,
            deletedCount: deletedCount,
            keptCount: keptCount,
            deletionRate: totalReviewed > 0 ? Double(deletedCount) / Double(totalReviewed) : 0.0
        )
    }
}

enum PhotoReviewAction: String, CaseIterable {
    case delete = "delete"
    case keep = "keep"
}

struct ProgressData: Codable {
    let reviewedPhotos: [String]
    let photoActions: [String: String]
    let lastReviewedIndex: Int
    let lastUpdated: Date
}

struct ProgressStatistics {
    let totalReviewed: Int
    let deletedCount: Int
    let keptCount: Int
    let deletionRate: Double
}
