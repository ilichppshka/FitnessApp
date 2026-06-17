import SwiftUI

extension Color {
    enum App {
        // Surfaces
        static let surface = Color(hex: "#0e0f0c")
        static let surfaceContainerLow = Color(hex: "#131410")
        static let surfaceContainerHigh = Color(hex: "#1f201c")
        static let surfaceContainerHighest = Color(hex: "#2a2b26")

        // Primary
        static let primary = Color(hex: "#d3f670")
        static let onPrimary = Color(hex: "#131a00")

        // Text
        static let onSurface = Color(hex: "#f5f4ee")
        static let onSurfaceMuted = Color(hex: "#8a8a82")

        // Effects — tint for neon glow & tinted shadows (distinct from primary)
        static let glow = Color(hex: "#BADB59")

        // Semantic
        static let danger = Color(hex: "#ff6e6e")
        static let live = Color(hex: "#ff5e5e")

        // Borders
        static let outlineVariant = Color(hex: "#484844")
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
