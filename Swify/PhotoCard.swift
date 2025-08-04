import SwiftUI
import Photos
import CoreLocation

struct PhotoCard: View {
    let asset: PHAsset
    let size: CGSize
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        ZStack {
            // Placeholder while loading
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size.width * 0.9, height: size.height * 0.7)
                .cornerRadius(20)
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width * 0.9, height: size.height * 0.7)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            } else if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Favorite indicator
            if asset.isFavorite {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding()
                    }
                    Spacer()
                }
            }
            
            // Photo info overlay
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let creationDate = asset.creationDate {
                            Text(DateFormatter.photoDate.string(from: creationDate))
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                        }
                        
                        if let location = asset.location {
                            Text("📍 \(formatLocation(location))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let targetSize = CGSize(
            width: size.width * 0.9 * UIScreen.main.scale,
            height: size.height * 0.7 * UIScreen.main.scale
        )
        
        photoManager.loadImage(for: asset, targetSize: targetSize) { loadedImage in
            self.image = loadedImage
            self.isLoading = false
        }
    }
    
    private func formatLocation(_ location: CLLocation) -> String {
        let geocoder = CLGeocoder()
        // In a real app, you'd want to cache this and handle it asynchronously
        return "Standort verfügbar"
    }
}

extension DateFormatter {
    static let photoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
}
