import SwiftUI

struct FeaturedExerciseCard: View {
    let label: String
    let title: String
    let subtitle: String
    var assetName: String?
    var onPlay: () -> Void

    var body: some View {
        PerformanceCard(padding: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        StatusDot()
                        SectionLabel(text: label)
                    }
                    Spacer()
                    if let assetName {
                        Text(assetName)
                            .font(Font.App.labelSm)
                            .foregroundStyle(Color.App.onSurface.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .font(Font.App.headlineLg)
                            .foregroundStyle(Color.App.onSurface)
                        Text(subtitle)
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    }

                    Spacer(minLength: Spacing.md)

                    Button(action: onPlay) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.App.onPrimary)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.App.primary))
                            .neonGlow(radius: 16)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview("Featured Exercise Card") {
    VStack {
        FeaturedExerciseCard(
            label: "Exercise of the Day",
            title: "Barbell Row",
            subtitle: "Lats · Rhomboids · Rear delts",
            assetName: "_lat_feature_barbell_row.json",
            onPlay: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
