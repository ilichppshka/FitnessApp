import Charts
import SwiftUI

struct OnboardingAnalyzePage: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            eyebrow: LocalizedStringResource("onboarding.analyze.eyebrow", table: "Onboarding"),
            title: LocalizedStringResource("onboarding.analyze.title", table: "Onboarding"),
            bodyText: LocalizedStringResource("onboarding.analyze.body", table: "Onboarding"),
            ctaTitle: LocalizedStringResource("onboarding.analyze.cta", table: "Onboarding"),
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
        Text(LocalizedStringResource("onboarding.analyze.demo.prsBadge", table: "Onboarding"))
            .font(Font.App.labelSm)
            .foregroundStyle(Color.App.onPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.App.primary))
    }

    private var volumeBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionLabel(text: String(localized: "onboarding.analyze.demo.volumeLabel", table: "Onboarding"))
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("72,840")
                    .font(Font.App.displayLg)
                    .foregroundStyle(Color.App.primary)
                Text(LocalizedStringResource("profileSetup.weight.unit", table: "Onboarding"))
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
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.App.onSurface.opacity(0.12))
            }
        }
        .frame(height: 80)
    }

    private var stats: some View {
        StatTriple(items: [
            StatItem(value: "14", label: String(localized: "onboarding.analyze.demo.sessionsLabel", table: "Onboarding")),
            StatItem(value: "21", unit: "d", label: String(localized: "onboarding.analyze.demo.streakLabel", table: "Onboarding")),
            StatItem(value: "11", unit: "h", label: String(localized: "onboarding.analyze.demo.timeLabel", table: "Onboarding"))
        ])
    }

    private static let demoSeries: [Double] = [22, 28, 26, 34, 31, 42, 48]
}

#Preview("Analyze") {
    OnboardingAnalyzePage(onContinue: {})
        .kineticTheme()
}
