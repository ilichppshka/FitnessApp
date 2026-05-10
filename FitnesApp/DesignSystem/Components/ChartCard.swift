import Charts
import Foundation
import SwiftUI

private let chartHeight: CGFloat = 160

struct ChartPoint: Identifiable, Hashable {
    let id: String
    let label: String
    let value: Double

    init(label: String, value: Double) {
        self.id = label
        self.label = label
        self.value = value
    }
}

struct ChartCard: View {
    let title: String
    let highlight: String?
    let totalValue: String
    var totalUnit: String?
    let points: [ChartPoint]
    var onHighlightTap: (() -> Void)?

    var body: some View {
        PerformanceCard(padding: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                header

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(totalValue)
                        .font(Font.App.headlineLg)
                        .foregroundStyle(Color.App.onSurface)
                    if let totalUnit {
                        Text(totalUnit)
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    }
                }

                chart
                    .frame(height: chartHeight)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            SectionLabel(text: title)
            Spacer()
            if let highlight {
                TextButton(
                    title: highlight,
                    trailingSystemName: "arrow.up",
                    action: { onHighlightTap?() }
                )
            }
        }
    }

    private var chart: some View {
        Chart(points) { point in
            AreaMark(
                x: .value("Period", point.label),
                y: .value("Volume", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.App.primary.opacity(0.6),
                        Color.App.primary.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Period", point.label),
                y: .value("Volume", point.value)
            )
            .foregroundStyle(Color.App.primary)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
        .chartYAxis(.hidden)
    }
}

#Preview("Chart Card") {
    VStack {
        ChartCard(
            title: "Weekly Tonnage",
            highlight: "This week",
            totalValue: "22,400",
            totalUnit: "kg",
            points: [
                ChartPoint(label: "Feb", value: 16_500),
                ChartPoint(label: "Mar", value: 18_900),
                ChartPoint(label: "Apr", value: 20_400),
                ChartPoint(label: "This wk", value: 22_400)
            ]
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
