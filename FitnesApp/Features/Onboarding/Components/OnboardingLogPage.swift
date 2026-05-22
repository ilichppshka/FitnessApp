import SwiftUI

struct OnboardingLogPage: View {
    let progressIndex: Int
    let totalSteps: Int
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            progressIndex: progressIndex,
            totalSteps: totalSteps,
            eyebrow: "onboarding.log.eyebrow",
            title: "onboarding.log.title",
            bodyText: "onboarding.log.body",
            ctaTitle: "onboarding.log.cta",
            onSkip: onSkip,
            onContinue: onContinue
        ) {
            demoCard
        }
    }

    private var demoCard: some View {
        PerformanceCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                setPill
                metricsRow
                completeButton
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var setPill: some View {
        Text("onboarding.log.demo.set")
            .font(Font.App.labelSm)
            .foregroundStyle(Color.App.onPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.App.primary))
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
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionLabel(text: String(localized: label))
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(value)
                    .font(Font.App.headlineLg)
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
            RoundedRectangle(cornerRadius: Radii.sm)
                .fill(Color.App.surface.opacity(0.6))
        )
    }

    private var completeButton: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
            Text("onboarding.log.demo.complete")
                .font(Font.App.titleLg)
        }
        .foregroundStyle(Color.App.onPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.primary)
        )
    }
}

#Preview("Log") {
    OnboardingLogPage(
        progressIndex: 1,
        totalSteps: 3,
        onSkip: {},
        onContinue: {}
    )
    .kineticTheme()
}
