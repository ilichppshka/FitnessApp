import SwiftUI

struct WeeklyStatsCard: View {
    let sessionsCompleted: Int
    let sessionsGoal: Int
    let totalVolume: String
    var volumeUnit: String = "kg"

    private var progress: Double {
        sessionsGoal > 0 ? Double(sessionsCompleted) / Double(sessionsGoal) : 0
    }

    var body: some View {
        PerformanceCard {
            HStack(alignment: .center, spacing: Spacing.lg) {
                ProgressRing(progress: progress, lineWidth: 4, size: 64) {
                    VStack(spacing: 0) {
                        Text("\(sessionsCompleted)/\(sessionsGoal)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.App.onSurface)
                        Text("SESSIONS")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    SectionLabel(text: "Total Volume")
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(totalVolume)
                            .font(Font.App.headlineLg)
                            .foregroundStyle(Color.App.onSurface)
                        Text(volumeUnit)
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview("Weekly Stats Card") {
    VStack(spacing: Spacing.lg) {
        WeeklyStatsCard(
            sessionsCompleted: 3,
            sessionsGoal: 5,
            totalVolume: "18,420"
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
