import SwiftUI
import Photos

struct PhotoDetailView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var progressManager: ProgressManager
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var showingUndoAlert = false
    @State private var actionHistory: [PhotoAction] = []
    @State private var showingActionFeedback = false
    @State private var lastActionText = ""
    @State private var lastActionColor = Color.green
    
    let sortMode: SortMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if !photoManager.filteredPhotos.isEmpty && currentIndex < photoManager.filteredPhotos.count {
                    mainPhotoView(geometry: geometry)
                    swipeOverlayView
                }
                
                actionFeedbackView
                bottomControlsView
            }
        }
        .onAppear {
            currentIndex = 0
            photoManager.preloadImages(around: currentIndex)
        }
        .onChange(of: currentIndex) { newIndex in
            photoManager.preloadImages(around: newIndex)
        }
    }
    
    private func mainPhotoView(geometry: GeometryProxy) -> some View {
        PhotoCard(
            asset: photoManager.filteredPhotos[currentIndex],
            size: geometry.size
        )
        .offset(dragOffset)
        .scaleEffect(1 - abs(dragOffset.width) / 1000 * 0.1)
        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let threshold: CGFloat = 150
                    
                    if abs(value.translation.x) > threshold {
                        if value.translation.x > 0 {
                            handleKeepAction()
                        } else {
                            handleDeleteAction()
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
    
    private var swipeOverlayView: some View {
        HStack {
            if dragOffset.width < -50 {
                deleteIndicatorView
            }
            
            Spacer()
            
            if dragOffset.width > 50 {
                keepIndicatorView
            }
        }
        .padding(.horizontal, 30)
        .allowsHitTesting(false)
    }
    
    private var deleteIndicatorView: some View {
        VStack {
            Image(systemName: "trash.fill")
                .font(.title)
                .foregroundColor(.white)
            Text("Löschen")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.red.opacity(0.8))
        .cornerRadius(12)
        .scaleEffect(min(abs(dragOffset.width) / 150, 1.0))
    }
    
    private var keepIndicatorView: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundColor(.white)
            Text("Behalten")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.green.opacity(0.8))
        .cornerRadius(12)
        .scaleEffect(min(dragOffset.width / 150, 1.0))
    }
    
    private var actionFeedbackView: some View {
        Group {
            if showingActionFeedback {
                VStack {
                    Spacer()
                    HStack {
                        Text(lastActionText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(lastActionColor.opacity(0.9))
                            .cornerRadius(12)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var bottomControlsView: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 30) {
                undoButton
                Spacer()
                progressIndicator
                Spacer()
                infoButton
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
    
    private var undoButton: some View {
        Button {
            undoLastAction()
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
        .disabled(actionHistory.isEmpty)
        .opacity(actionHistory.isEmpty ? 0.5 : 1.0)
    }
    
    private var progressIndicator: some View {
        VStack {
            Text("\(currentIndex + 1) / \(photoManager.filteredPhotos.count)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            ProgressView(value: Double(currentIndex + 1), total: Double(photoManager.filteredPhotos.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .frame(width: 100)
        }
    }
    
    private var infoButton: some View {
        Button {
            // Show photo info
        } label: {
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
    }
    
    private func handleDeleteAction() {
        guard currentIndex < photoManager.filteredPhotos.count else { return }
        
        let asset = photoManager.filteredPhotos[currentIndex]
        let action = PhotoAction(
            type: .delete,
            asset: asset,
            index: currentIndex,
            timestamp: Date()
        )
        
        photoManager.deletePhoto(asset) { success in
            if success {
                actionHistory.append(action)
                progressManager.markAsReviewed(asset.localIdentifier, action: .delete)
                
                // Keep history to last 2 actions
                if actionHistory.count > 2 {
                    actionHistory.removeFirst()
                }
                
                showActionFeedback(text: "Foto gelöscht", color: .red)
                moveToNextPhoto()
            }
        }
    }
    
    private func handleKeepAction() {
        guard currentIndex < photoManager.filteredPhotos.count else { return }
        
        let asset = photoManager.filteredPhotos[currentIndex]
        let action = PhotoAction(
            type: .keep,
            asset: asset,
            index: currentIndex,
            timestamp: Date()
        )
        
        photoManager.toggleFavorite(asset) { success in
            if success {
                actionHistory.append(action)
                progressManager.markAsReviewed(asset.localIdentifier, action: .keep)
                
                // Keep history to last 2 actions
                if actionHistory.count > 2 {
                    actionHistory.removeFirst()
                }
                
                showActionFeedback(text: "Als Favorit markiert", color: .green)
                moveToNextPhoto()
            }
        }
    }
    
    private func moveToNextPhoto() {
        withAnimation(.spring()) {
            dragOffset = .zero
            
            if currentIndex < photoManager.filteredPhotos.count - 1 {
                currentIndex += 1
            } else {
                // All photos reviewed
                currentIndex = 0
            }
        }
    }
    
    private func undoLastAction() {
        guard let lastAction = actionHistory.last else { return }
        
        switch lastAction.type {
        case .delete:
            // Note: Undeleting photos is complex with PhotoKit
            // For now, we'll just remove from history and show message
            showActionFeedback(text: "Löschen kann nicht rückgängig gemacht werden", color: .orange)
        case .keep:
            photoManager.toggleFavorite(lastAction.asset) { success in
                if success {
                    progressManager.removeReview(lastAction.asset.localIdentifier)
                    showActionFeedback(text: "Favorit entfernt", color: .blue)
                }
            }
        }
        
        actionHistory.removeLast()
    }
    
    private func showActionFeedback(text: String, color: Color) {
        lastActionText = text
        lastActionColor = color
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingActionFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingActionFeedback = false
            }
        }
    }
}

struct PhotoAction {
    enum ActionType {
        case delete
        case keep
    }
    
    let type: ActionType
    let asset: PHAsset
    let index: Int
    let timestamp: Date
}

#Preview {
    PhotoDetailView(sortMode: .chronological)
        .environmentObject(PhotoManager())
        .environmentObject(ProgressManager())
}
