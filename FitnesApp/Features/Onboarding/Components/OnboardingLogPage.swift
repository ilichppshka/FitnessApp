import SwiftUI

struct OnboardingLogPage: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            eyebrow: "onboarding.log.eyebrow",
            title: "onboarding.log.title",
            bodyText: "onboarding.log.body",
            ctaTitle: "onboarding.log.cta",
            onContinue: onContinue
        ) {
            demoCard
        }
    }

    private var demoCard: some View {
        PerformanceCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                exerciseHeader
                metricsRow
                completeButton
            }
        }
        .overlay(alignment: .topTrailing) {
            setPill
                .offset(x: Spacing.xs, y: -Spacing.md)
        }
        .overlay(alignment: .bottomLeading) {
            deltaPill
                .offset(x: -Spacing.xs, y: Spacing.md)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.md)
    }

    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionLabel(text: String(localized: "onboarding.log.demo.exercise"))
            Text("onboarding.log.demo.name")
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var setPill: some View {
        HStack(spacing: Spacing.xs) {
            StatusDot(size: 6)
            Text("onboarding.log.demo.set")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface)
                .tracking(0.8)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule().fill(Color.App.surfaceContainerHigh)
        )
        .overlay(
            Capsule().strokeBorder(Color.App.outlineVariant.opacity(0.5), lineWidth: 1)
        )
    }

    private var deltaPill: some View {
        Text("onboarding.log.demo.delta")
            .font(Font.App.labelSm)
            .foregroundStyle(Color.App.primary)
            .tracking(0.4)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule().fill(Color.App.surfaceContainerHigh)
            )
            .overlay(
                Capsule().strokeBorder(Color.App.outlineVariant.opacity(0.5), lineWidth: 1)
            )
    }

    private var metricsRow: some View {
        HStack(spacing: Spacing.md) {
            metricCell(label: "onboarding.log.demo.weight", value: "75", unit: "profileSetup.weight.unit")
            metricCell(label: "onboarding.log.demo.reps", value: "8", unit: nil)
        }
    }

    private func metricCell(
        label: LocalizedStringResource,
        value: String,
        unit: LocalizedStringResource?
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: label))
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(value)
                    .font(Font.App.displayLg)
                    .foregroundStyle(Color.App.onSurface)
                if let unit {
                    Text(unit)
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerLow)
        )
    }

    private var completeButton: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
            Text("onboarding.log.demo.complete")
                .font(Font.App.titleLg)
        }
        .foregroundStyle(Color.App.onPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.primary)
        )
        .neonGlow(radius: 18, opacity: 0.5)
    }
}

#Preview("Log") {
    OnboardingLogPage(onContinue: {})
        .kineticTheme()
}
