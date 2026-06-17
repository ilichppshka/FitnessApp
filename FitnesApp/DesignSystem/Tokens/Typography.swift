import SwiftUI

extension Font {
    enum App {
        // Space Grotesk — data & headlines
        static let displayLg = Font.custom("SpaceGrotesk-Bold", size: 56)
        static let headlineLg = Font.custom("SpaceGrotesk-Medium", size: 32)

        // SF Pro — functional UI
        static let titleLg = Font.system(size: 22, weight: .semibold)
        static let bodyMd = Font.system(size: 14, weight: .regular)
        static let labelSm = Font.system(size: 11, weight: .bold)
    }
}

// MARK: - Text style modifier (font + tracking + case)

enum KineticTextStyle {
    case displayLg
    case headlineLg
    case titleLg
    case bodyMd
    case labelSm
}

extension View {
    func kineticText(_ style: KineticTextStyle) -> some View {
        modifier(KineticTextModifier(style: style))
    }
}

private struct KineticTextModifier: ViewModifier {
    let style: KineticTextStyle

    func body(content: Content) -> some View {
        switch style {
        case .displayLg:
            content
                .font(Font.App.displayLg)
                .tracking(-1.1)
        case .headlineLg:
            content
                .font(Font.App.headlineLg)
                .tracking(-0.32)
        case .titleLg:
            content
                .font(Font.App.titleLg)
        case .bodyMd:
            content
                .font(Font.App.bodyMd)
        case .labelSm:
            content
                .font(Font.App.labelSm)
                .tracking(0.55)
                .textCase(.uppercase)
        }
    }
}
