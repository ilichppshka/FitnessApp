import SwiftUI

extension Color {
    enum App {
        // Surfaces
        static let surface = Color(hex: "#0e0f0c")
        static let surfaceContainerLow = Color(hex: "#131410")
        static let surfaceContainerHigh = Color(hex: "#1f201c")

        // Primary
        static let primary = Color(hex: "#d3f670")
        static let onPrimary = Color(hex: "#131a00")

        // Text
        static let onSurface = Color(hex: "#f5f4ee")

        // Borders
        static let outlineVariant = Color(hex: "#484844")
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
