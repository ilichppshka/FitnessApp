import SwiftUI

private let dockButtonWidth: CGFloat = 160

struct BottomActionDock<Action: View>: View {
    let primaryText: String
    var secondaryText: String?
    @ViewBuilder var action: () -> Action

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(primaryText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.App.onSurface)
                if let secondaryText {
                    Text(secondaryText)
                        .font(Font.App.labelSm)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
            }

            Spacer(minLength: Spacing.md)

            action()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    Color.App.surface.opacity(0.0),
                    Color.App.surface.opacity(0.9),
                    Color.App.surface
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview("Bottom Action Dock") {
    ZStack(alignment: .bottom) {
        Color.App.surface.ignoresSafeArea()

        BottomActionDock(
            primaryText: "5 EXERCISES · 18 SETS",
            secondaryText: "~48 min total",
            action: {
                KineticButton(
                    title: "Save Plan",
                    trailingSystemName: "chevron.right",
                    action: {}
                )
                .frame(width: dockButtonWidth)
            }
        )
    }
    .preferredColorScheme(.dark)
}
