import SwiftUI

enum ChipStyle {
    case selected
    case outline
    case subtle
    case delta
}

struct Chip: View {
    let title: String
    var style: ChipStyle = .subtle
    var leadingSystemName: String?
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) { label }
                .buttonStyle(ChipPressStyle())
        } else {
            label
        }
    }

    private var label: some View {
        HStack(spacing: Spacing.xs) {
            if let leadingSystemName {
                Image(systemName: leadingSystemName)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(title)
                .font(Font.App.labelSm)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Capsule().fill(background))
        .overlay(Capsule().strokeBorder(border, lineWidth: 1))
    }

    private var foreground: Color {
        switch style {
        case .selected: Color.App.onPrimary
        case .outline:  Color.App.onSurface
        case .subtle:   Color.App.onSurface.opacity(0.7)
        case .delta:    Color.App.primary
        }
    }

    private var background: Color {
        switch style {
        case .selected: Color.App.primary
        case .outline:  .clear
        case .subtle:   Color.App.surfaceContainerHigh
        case .delta:    Color.App.primary.opacity(0.15)
        }
    }

    private var border: Color {
        switch style {
        case .selected: .clear
        case .outline:  Color.App.outlineVariant
        case .subtle:   .clear
        case .delta:    .clear
        }
    }
}

private struct ChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("Chip") {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.sm) {
            Chip(title: "All 258", style: .selected, action: {})
            Chip(title: "Chest", style: .outline, action: {})
            Chip(title: "Back", style: .outline, action: {})
        }
        HStack(spacing: Spacing.sm) {
            Chip(title: "TODAY · WEEK 3", style: .subtle, leadingSystemName: "circle.fill")
            Chip(title: "4 LEFT", style: .subtle)
        }
        HStack(spacing: Spacing.sm) {
            Chip(title: "+18.2%", style: .delta, leadingSystemName: "arrow.up")
            Chip(title: "+5kg", style: .delta, leadingSystemName: "arrow.up")
        }
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
