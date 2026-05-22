import Charts
import SwiftUI

struct OnboardingAnalyzePage: View {
    let progressIndex: Int
    let totalSteps: Int
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            progressIndex: progressIndex,
            totalSteps: totalSteps,
            eyebrow: "onboarding.analyze.eyebrow",
            title: "onboarding.analyze.title",
            bodyText: "onboarding.analyze.body",
            ctaTitle: "onboarding.analyze.cta",
            onSkip: onSkip,
            onContinue: onContinue
        ) {
            demoCard
        }
    }

    private var demoCard: some View {
        PerformanceCard {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                prsBadge
                volumeBlock
                chart
                stats
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var prsBadge: some View {
        Text("onboarding.analyze.demo.prsBadge")
            .font(Font.App.labelSm)
            .foregroundStyle(Color.App.onPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.App.primary))
    }

    private var volumeBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionLabel(text: String(localized: "onboarding.analyze.demo.volumeLabel"))
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("72,840")
                    .font(Font.App.displayLg)
                    .foregroundStyle(Color.App.primary)
                Text("profileSetup.weight.unit")
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(Array(Self.demoSeries.enumerated()), id: \.offset) { index, value in
                AreaMark(
                    x: .value("Day", index),
                    y: .value("Tonnage", value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color.App.primary.opacity(0.45), Color.App.primary.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Day", index),
                    y: .value("Tonnage", value)
                )
                .foregroundStyle(Color.App.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 80)
    }

    private var stats: some View {
        StatTriple(items: [
            StatItem(value: "14", label: String(localized: "onboarding.analyze.demo.sessionsLabel")),
            StatItem(value: "21", unit: "d", label: String(localized: "onboarding.analyze.demo.streakLabel")),
            StatItem(value: "11", unit: "h", label: String(localized: "onboarding.analyze.demo.timeLabel"))
        ])
    }

    private static let demoSeries: [Double] = [22, 28, 26, 34, 31, 42, 48]
}

#Preview("Analyze") {
    OnboardingAnalyzePage(
        progressIndex: 2,
        totalSteps: 3,
        onSkip: {},
        onContinue: {}
    )
    .kineticTheme()
}
