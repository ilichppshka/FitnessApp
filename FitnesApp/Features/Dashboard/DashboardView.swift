import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel: DashboardViewModel
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
        _viewModel = State(initialValue: DashboardViewModel(userRepository: userRepository))
    }

    var body: some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(spacing: Spacing.lg) {
                    DashboardGreetingHeader(
                        dateLabel: viewModel.headerDateLabel,
                        greeting: viewModel.greeting
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    WeekCalendarStrip(
                        week: viewModel.weekDates,
                        selectedDate: $viewModel.selectedDate,
                        today: viewModel.today
                    )
                    .padding(.horizontal, Spacing.md)

                    nextSessionSection
                        .padding(.horizontal, Spacing.md)

                    thisWeekSection
                        .padding(.horizontal, Spacing.md)

                    quickStartRow
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.lg)
                }
            }
        }
        .task {
            await viewModel.loadInitial()
        }
    }

    private var nextSessionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "dashboard.next_session"))
            NextWorkoutCard(
                scheduleTag: String(localized: "dashboard.hero.today_week \(viewModel.weekNumber)"),
                focusLabel: String(localized: "dashboard.hero.muscle_focus"),
                title: String(localized: "dashboard.mock.workout_name"),
                stats: [
                    StatItem(value: "\(viewModel.mockExercises)", label: String(localized: "dashboard.stat.exercises")),
                    StatItem(value: "\(viewModel.mockMinutes)", label: String(localized: "dashboard.stat.min")),
                    StatItem(value: "\(viewModel.mockSets)", label: String(localized: "dashboard.stat.sets"))
                ],
                muscleGroups: viewModel.mockMuscles,
                ctaTitle: String(localized: "dashboard.cta.start"),
                onStart: { router.presentActiveWorkout(sessionID: UUID()) }
            )
        }
    }

    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                SectionLabel(text: String(localized: "dashboard.this_week"))
                Spacer()
                Text(viewModel.weekRangeLabel)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
            WeeklyStatsCard(
                sessionsCompleted: viewModel.sessionsCompleted,
                sessionsGoal: viewModel.sessionsGoal,
                totalVolume: viewModel.totalVolume,
                volumeUnit: viewModel.volumeUnit
            )
        }
    }
    private var quickStartRow: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            quickStartCard
                .frame(maxHeight: .infinity)
            latestPRCard
                .frame(maxHeight: .infinity)
        }
    }

    private var quickStartCard: some View {
        PerformanceCard(padding: Spacing.md, action: { router.presentActiveWorkout(sessionID: UUID()) }, content: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .center, spacing: Spacing.sm) {
                    RoundedRectangle(cornerRadius: Radii.sm)
                        .fill(Color.App.primary.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.App.primary)
                        )
                    Text(String(localized: "dashboard.quickstart.title"))
                        .font(Font.App.titleLg)
                        .foregroundStyle(Color.App.onSurface)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(String(localized: "dashboard.quickstart.subtitle"))
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        })
    }

    private var latestPRCard: some View {
        PerformanceCard(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionLabel(text: String(localized: "dashboard.latest_pr.label"))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(viewModel.mockPRWeight)
                        .font(Font.App.headlineLg)
                        .foregroundStyle(Color.App.onSurface)
                    Text(viewModel.mockPRUnit)
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
                Text("\(viewModel.mockPRExercise) · \(viewModel.mockPRTimeAgo)")
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
    }

}

#if DEBUG
#Preview("Dashboard") {
    // swiftlint:disable:next force_try
    let mc = try! ModelContainer.makePreview()
    return DashboardView(userRepository: SwiftDataUserRepository(context: mc.mainContext))
        .modelContainer(mc)
        .environment(AppRouter())
        .kineticTheme()
}
#endif
