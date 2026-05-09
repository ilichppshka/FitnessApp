import SwiftData
import SwiftUI

@main
struct FitnesAppApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer.makeProduction()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
