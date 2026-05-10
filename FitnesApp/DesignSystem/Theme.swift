import SwiftUI

struct KineticTheme: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.App.surface.ignoresSafeArea())
            .foregroundStyle(Color.App.onSurface)
            .tint(Color.App.primary)
            .font(Font.App.bodyMd)
            .preferredColorScheme(.dark)
    }
}

extension View {
    func kineticTheme() -> some View {
        modifier(KineticTheme())
    }
}
