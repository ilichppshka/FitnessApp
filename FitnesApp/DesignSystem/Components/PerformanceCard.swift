import SwiftUI

struct PerformanceCard<Content: View>: View {
    var padding: CGFloat = Spacing.lg
    var action: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        if let action {
            Button(action: action) {
                cardBody
            }
            .buttonStyle(PerformanceCardPressStyle())
        } else {
            cardBody
        }
    }

    private var cardBody: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radii.md)
                    .fill(Color.App.surfaceContainerHigh)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .strokeBorder(Color.App.outlineVariant.opacity(0.4), lineWidth: 1)
            )
    }
}

private struct PerformanceCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("Performance Card") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            PerformanceCard {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("ТОННАЖ ЗА НЕДЕЛЮ")
                        .font(Font.App.labelSm)
                        .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    Text("12 480 кг")
                        .font(Font.App.displayLg)
                        .foregroundStyle(Color.App.primary)
                }
            }

            PerformanceCard(action: {}) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Push Day")
                            .font(Font.App.titleLg)
                            .foregroundStyle(Color.App.onSurface)
                        Text("4 упражнения · 45 мин")
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.App.onSurface.opacity(0.4))
                }
            }

            PerformanceCard(padding: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.App.primary)
                    VStack(alignment: .leading) {
                        Text("Streak")
                            .font(Font.App.labelSm)
                            .foregroundStyle(Color.App.onSurface.opacity(0.6))
                        Text("7 дней")
                            .font(Font.App.titleLg)
                            .foregroundStyle(Color.App.onSurface)
                    }
                }
            }
        }
        .padding(Spacing.lg)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
