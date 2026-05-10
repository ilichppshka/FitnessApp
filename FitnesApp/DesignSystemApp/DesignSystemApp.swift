import SwiftUI

@main
struct DesignSystemApp: App {
    var body: some Scene {
        WindowGroup {
            DesignSystemRootView()
                .kineticTheme()
        }
    }
}
