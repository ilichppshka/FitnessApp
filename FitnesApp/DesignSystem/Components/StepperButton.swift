import SwiftUI
import UIKit

enum StepperKind {
    case minus
    case plus

    var systemName: String {
        switch self {
        case .minus: "minus"
        case .plus:  "plus"
        }
    }
}

struct StepperButton: View {
    let kind: StepperKind
    var size: CGFloat = 44
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Image(systemName: kind.systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Color.App.onSurface)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.App.surfaceContainerHigh))
                .overlay(
                    Circle().strokeBorder(
                        Color.App.outlineVariant.opacity(0.3),
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(StepperPressStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }
}

private struct StepperPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("Stepper Button") {
    HStack(spacing: Spacing.lg) {
        StepperButton(kind: .minus, action: {})
        StepperButton(kind: .plus, action: {})
        StepperButton(kind: .plus, isEnabled: false, action: {})
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
