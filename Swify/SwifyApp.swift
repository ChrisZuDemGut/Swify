import SwiftUI

@main
struct SwifyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PhotoManager())
                .environmentObject(ProgressManager())
        }
    }
}
