import SwiftData
import SwiftUI

@main
struct FitnesAppApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer.makeProduction()
            try DataSeeder.seedIfNeeded(modelContainer.mainContext)
        } catch {
            fatalError("Failed to bootstrap ModelContainer: \(error)")
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
