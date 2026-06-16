import SwiftData
import SwiftUI

@main
struct FitnesAppApp: App {
    @State private var container: DIContainer
    @State private var router = AppRouter()
    private let modelContainer: ModelContainer

    init() {
        do {
            let mc = try ModelContainer.makeAppLaunch()
            if !ProcessInfo.processInfo.isRunningUnitTests {
                try DataSeeder.seedIfNeeded(mc.mainContext)
            }
            self.modelContainer = mc
            self._container = State(initialValue: DIContainer(modelContext: mc.mainContext))
        } catch {
            fatalError("Failed to bootstrap ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(router)
                .kineticTheme()
        }
        .modelContainer(modelContainer)
    }
}
