import SwiftUI
import Photos

enum SortMode: String, CaseIterable {
    case random = "Zufällig"
    case chronological = "Chronologisch"
    case favoritesOnly = "Nur Favoriten"
}

struct ContentView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var progressManager: ProgressManager
    @State private var showingSortOptions = false
    @State private var currentSortMode: SortMode = .chronological
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Liquid Glass Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if photoManager.hasPermission {
                    if photoManager.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Fotos werden geladen...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    } else if photoManager.filteredPhotos.isEmpty {
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                                .padding()
                            Text("Keine Fotos verfügbar")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        PhotoDetailView(sortMode: currentSortMode)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Fotogalerie-Zugriff erforderlich")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Swify benötigt Zugriff auf Ihre Fotos, um sie zu verwalten und zu organisieren.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Zugriff gewähren") {
                            photoManager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                }
            }
            .navigationTitle("Swify")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSortOptions = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.primary)
                    }
                    .disabled(!photoManager.hasPermission || photoManager.isLoading)
                }
                
                if photoManager.hasPermission && !photoManager.isLoading {
                    ToolbarItem(placement: .navigationBarLeading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(progressManager.reviewedPhotos.count)")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("bewertet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSortOptions) {
                SortingOptionsView(selectedMode: $currentSortMode)
                    .presentationDetents([.medium])
            }
            .onAppear {
                photoManager.checkPermissionStatus()
            }
            .onChange(of: currentSortMode) { newMode in
                photoManager.setSortMode(newMode)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PhotoManager())
        .environmentObject(ProgressManager())
}
