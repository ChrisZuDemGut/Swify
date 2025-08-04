import SwiftUI

struct SortingOptionsView: View {
    @Binding var selectedMode: SortMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Sortierung")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Wählen Sie aus, wie Ihre Fotos angezeigt werden sollen")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(SortMode.allCases, id: \.self) { mode in
                        SortModeRow(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            selectedMode = mode
                            dismiss()
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
            }
            .background(
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
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SortModeRow: View {
    let mode: SortMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: iconForMode(mode))
                            .font(.title2)
                            .foregroundColor(isSelected ? .blue : .primary)
                        
                        Text(mode.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(descriptionForMode(mode))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForMode(_ mode: SortMode) -> String {
        switch mode {
        case .random:
            return "shuffle"
        case .chronological:
            return "calendar"
        case .favoritesOnly:
            return "heart.fill"
        }
    }
    
    private func descriptionForMode(_ mode: SortMode) -> String {
        switch mode {
        case .random:
            return "Fotos werden in zufälliger Reihenfolge angezeigt"
        case .chronological:
            return "Fotos werden nach Aufnahmedatum sortiert (neueste zuerst)"
        case .favoritesOnly:
            return "Zeigt nur Fotos an, die bereits als Favoriten markiert sind"
        }
    }
}

#Preview {
    SortingOptionsView(selectedMode: .constant(.chronological))
}
