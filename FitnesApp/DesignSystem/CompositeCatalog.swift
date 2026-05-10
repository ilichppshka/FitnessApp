#if DEBUG
import Foundation
import SwiftUI

private let dockButtonWidth: CGFloat = 160

private enum DemoRange: String, CaseIterable, Hashable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3M"
    case year = "Year"
    case all = "All"
}

private struct CompositeCatalog: View {
    @State private var selected: Date = Calendar.current
        .date(from: DateComponents(year: 2026, month: 4, day: 16))!
    @State private var range: DemoRange = .month
    @State private var weight: Double = 75
    @State private var reps: Int = 8
    @State private var rest = "02:00"
    @State private var scrubProgress: Double = 0.45
    @State private var autoStart = true
    @State private var sets: [ExerciseBuilderSet] = [
        ExerciseBuilderSet(weight: "60", reps: "12"),
        ExerciseBuilderSet(weight: "70", reps: "10"),
        ExerciseBuilderSet(weight: "75", reps: "8"),
        ExerciseBuilderSet(weight: "75", reps: "8")
    ]
    @State private var builderExpanded: Bool = true
    @State private var builderCollapsed: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header
                dashboardSection
                builderSection
                librarySection
                activeWorkoutSection
                progressSection
                settingsSection
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xl)
        }
        .kineticTheme()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("KINETIC LABORATORY")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.primary)
            Text("Composite Catalog")
                .font(Font.App.headlineLg)
            Text("Композиты, сгруппированные по экранам")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
        }
    }

    private var dashboardSection: some View {
        screenSection(title: "Dashboard") {
            TopBar(
                leading: { AvatarCircle(initial: "A") },
                trailing: { IconChip(systemName: "bell", action: {}) }
            )

            ScreenHeader(label: "Thursday · Apr 16", title: "Hey, Alex")

            WeekCalendarStrip(
                week: demoWeek(),
                selectedDate: $selected,
                today: Calendar.current
                    .date(from: DateComponents(year: 2026, month: 4, day: 16))!
            )

            SectionLabel(text: "Next Session")

            NextWorkoutCard(
                scheduleTag: "TODAY · WEEK 3",
                focusLabel: "Muscle Focus",
                title: "Back Day",
                stats: [
                    StatItem(value: "6", label: "Exercises"),
                    StatItem(value: "45", unit: "min", label: "Time"),
                    StatItem(value: "22", label: "Sets")
                ],
                muscleGroups: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
                onStart: {}
            )

            SectionLabel(text: "This Week · Apr 13 – Apr 19")

            WeeklyStatsCard(
                sessionsCompleted: 3,
                sessionsGoal: 5,
                totalVolume: "18,420"
            )
        }
    }

    private var builderSection: some View {
        screenSection(title: "Workout Builder") {
            TopBar(
                leading: { IconChip(systemName: "chevron.left", action: {}) },
                trailing: {
                    TextButton(
                        title: "Save Draft",
                        style: .pill,
                        foreground: Color.App.onSurface,
                        action: {}
                    )
                }
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                ScreenHeader(label: "New Program · Day 1", title: "Push Day")
                HStack(spacing: Spacing.xs) {
                    StatusDot()
                    Text("Auto-saved · 12s ago")
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.6))
                }
            }

            StatTriple(items: [
                StatItem(value: "5", label: "Exercises"),
                StatItem(value: "48", unit: "min", label: "Est. Time"),
                StatItem(value: "18", label: "Total Sets")
            ])

            SectionLabel(text: "Exercises · Drag to reorder")

            ExerciseBuilderCard(
                index: 1,
                title: "Barbell Bench Press",
                subtitle: "Chest · Triceps · Front delts",
                isExpanded: $builderExpanded,
                sets: $sets,
                restText: $rest,
                onAddSet: {
                    sets.append(ExerciseBuilderSet(weight: "", reps: ""))
                },
                onRemoveSet: { id in
                    sets.removeAll { $0.id == id }
                }
            )

            ExerciseBuilderCard(
                index: 2,
                title: "Incline Dumbbell Press",
                subtitle: "Upper chest · Front delts",
                isExpanded: $builderCollapsed,
                sets: .constant([]),
                restText: .constant("02:00"),
                collapsedSummary: "4 × 10–12",
                onAddSet: {},
                onRemoveSet: { _ in }
            )

            BottomActionDock(
                primaryText: "5 EXERCISES · 18 SETS",
                secondaryText: "~48 min total"
            ) {
                KineticButton(
                    title: "Save Plan",
                    trailingSystemName: "chevron.right",
                    action: {}
                )
                .frame(width: dockButtonWidth)
            }
        }
    }

    private var librarySection: some View {
        screenSection(title: "Exercise Library") {
            TopBar(
                leading: { IconChip(systemName: "chevron.left", action: {}) },
                trailing: { IconChip(systemName: "line.3.horizontal.decrease", action: {}) }
            )

            ScreenHeader(label: "Library", title: "Exercises", accent: "258")

            SearchField(
                placeholder: "Search 258 exercises...",
                text: .constant(""),
                trailingMeta: "3K"
            )

            HStack(spacing: Spacing.sm) {
                Chip(title: "All 258", style: .selected, action: {})
                Chip(title: "Chest", style: .outline, action: {})
                Chip(title: "Back", style: .outline, action: {})
                Chip(title: "Legs", style: .outline, action: {})
            }

            FeaturedExerciseCard(
                label: "Exercise of the Day",
                title: "Barbell Row",
                subtitle: "Lats · Rhomboids · Rear delts",
                assetName: "_lat_feature_barbell_row.json",
                onPlay: {}
            )

            HStack {
                SectionLabel(text: "Recent")
                Text("2")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.4))
                Spacer()
                TextButton(title: "Sort", trailingSystemName: "arrow.up.arrow.down", action: {})
            }

            ExerciseListItem(
                title: "Barbell Deadlift",
                subtitle: "Posterior chain · Glutes · Hams",
                difficulty: "Advanced",
                prText: "142.5kg",
                onTap: {},
                onAdd: {}
            )
            ExerciseListItem(
                title: "Pull-up",
                subtitle: "Lats · Biceps",
                difficulty: "Intermediate",
                prText: "+15kg",
                onTap: {},
                onAdd: {}
            )
        }
    }

    private var activeWorkoutSection: some View {
        screenSection(title: "Active Workout") {
            TopBar(
                leading: { IconChip(systemName: "xmark", action: {}) },
                center: {
                    VStack(spacing: 0) {
                        Text("SESSION")
                            .font(Font.App.labelSm)
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        Text("24:18")
                            .font(Font.App.titleLg)
                            .monospacedDigit()
                    }
                },
                trailing: { IconChip(systemName: "ellipsis", action: {}) }
            )

            MascotStage(
                state: .active,
                statusLabel: "LIVE · TECHNIQUE",
                assetName: "_bench_press.lottie",
                scrubProgress: $scrubProgress,
                startText: "0:00",
                currentText: "2:18"
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    SectionLabel(text: "Exercise 2 of 5 · Chest")
                    Spacer()
                    ProgressDots(total: 4, completed: 3)
                }
                Text("Barbell Bench Press")
                    .font(Font.App.headlineLg)
                Text("Set 3 of 4 · Last set: 70kg × 10")
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }

            SetInputPanel(
                weightColumn: SetInputColumn(label: "Weight", unit: "kg", deltaText: "+5kg"),
                repsColumn: SetInputColumn(label: "Reps", unit: "reps"),
                weight: $weight,
                reps: $reps
            )

            KineticButton(
                title: "Complete Set  75 × 8",
                trailingSystemName: "checkmark",
                action: {}
            )

            RestTimerBar(
                label: "Rest · next set in",
                timeText: "1:23",
                onMinus15: {},
                onPlus15: {},
                onSkip: {}
            )
        }
    }

    private var progressSection: some View {
        screenSection(title: "Progress") {
            TopBar(
                leading: { IconChip(systemName: "chevron.left", action: {}) },
                trailing: { IconChip(systemName: "arrow.down.to.line", action: {}) }
            )

            ScreenHeader(label: "Analytics", title: "Progress")

            RangeTabs(
                ranges: DemoRange.allCases,
                selection: $range,
                title: { $0.rawValue }
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                SectionLabel(text: "Total Volume · 4 Weeks")
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("72,840")
                        .font(Font.App.displayLg)
                    Text("kg")
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
                HStack(spacing: Spacing.sm) {
                    DeltaPill(direction: .up, value: "+18.2%")
                    Text("vs previous 4 weeks")
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
            }

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

            HStack(spacing: Spacing.sm) {
                StatTile(
                    systemName: "dumbbell.fill",
                    label: "Sessions",
                    value: "14",
                    delta: DeltaPill(direction: .up, value: "+2")
                )
                StatTile(
                    systemName: "clock",
                    label: "Time",
                    value: "11h 24m",
                    delta: DeltaPill(direction: .up, value: "+1h")
                )
            }
        }
    }

    private var settingsSection: some View {
        screenSection(title: "Settings") {
            TopBar(
                leading: { IconChip(systemName: "chevron.left", action: {}) },
                trailing: { TextButton(title: "Edit", action: {}) }
            )

            ScreenHeader(label: "Profile", title: "Settings")

            ProfileCard(
                initial: "A",
                name: "Alex Morgan",
                secondary: "alex@kinetic.app · Member since Feb 2024",
                stats: [
                    StatItem(value: "78", unit: "kg", label: "Weight"),
                    StatItem(value: "182", unit: "cm", label: "Height"),
                    StatItem(value: "3", label: "Level")
                ],
                action: {}
            )

            MascotCard(
                label: "Your Mascot",
                title: "Athlete · Default",
                caption: "Tap to change character",
                remainingCount: 4,
                action: {}
            )

            SettingsGroup(title: "Training") {
                SettingsRow(
                    systemName: "clock",
                    title: "Default rest timer",
                    value: "01:30",
                    action: {}
                )
                Divider().background(Color.App.outlineVariant.opacity(0.2))
                SettingsRow(
                    systemName: "scalemass",
                    title: "Weight unit",
                    value: "Kilograms",
                    action: {}
                )
                Divider().background(Color.App.outlineVariant.opacity(0.2))
                SettingsRow(
                    systemName: "checkmark.circle",
                    title: "Auto-start rest timer",
                    trailing: { KineticToggle(isOn: $autoStart) }
                )
            }
        }
    }

    @ViewBuilder
    private func screenSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Rectangle()
                    .fill(Color.App.primary)
                    .frame(width: 3, height: 18)
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.App.onSurface)
                    .tracking(1.2)
            }
            VStack(alignment: .leading, spacing: Spacing.md) {
                content()
            }
        }
    }

    private func demoWeek() -> [Date] {
        let calendar = Calendar.current
        let base = calendar
            .date(from: DateComponents(year: 2026, month: 4, day: 16))!
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 3, to: base)
        }
    }
}

#Preview("Composite Catalog") {
    CompositeCatalog()
}
#endif
