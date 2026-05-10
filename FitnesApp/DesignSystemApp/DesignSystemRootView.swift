import SwiftUI

struct DesignSystemRootView: View {
    var body: some View {
        TabView {
            ComponentCatalog()
                .tabItem {
                    Label("Atoms", systemImage: "circle.grid.2x2")
                }

            CompositeCatalog()
                .tabItem {
                    Label("Composites", systemImage: "square.grid.3x3.square")
                }
        }
        .tint(Color.App.primary)
    }
}
