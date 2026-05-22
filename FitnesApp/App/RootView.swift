import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(DIContainer.self) private var container
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var bindableRouter = router

        TabView(selection: $bindableRouter.selectedTab) {
            dashboardTab
                .tag(AppRouter.Tab.dashboard)
                .tabItem { Label("Главная", systemImage: "house.fill") }

            libraryTab
                .tag(AppRouter.Tab.library)
                .tabItem { Label("Упражнения", systemImage: "dumbbell.fill") }

            placeholderTab(title: "Прогресс", systemImage: "chart.bar.fill")
                .tag(AppRouter.Tab.progress)
                .tabItem { Label("Прогресс", systemImage: "chart.bar.fill") }

            placeholderTab(title: "Настройки", systemImage: "gearshape.fill")
                .tag(AppRouter.Tab.settings)
                .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
        }
        .tint(Color.App.primary)
        .fullScreenCover(
            isPresented: Binding(
                get: { router.presentedActiveSessionID != nil },
                set: { if !$0 { router.dismissActiveWorkout() } }
            )
        ) {
            if let sessionID = router.presentedActiveSessionID {
                ActiveWorkoutPlaceholderView(sessionID: sessionID) {
                    router.dismissActiveWorkout()
                }
            }
        }
    }

    private var dashboardTab: some View {
        DashboardView(
            vm: DashboardViewModel(
                analytics: container.analyticsService,
                workouts: container.workoutRepository,
                workoutService: container.workoutService
            ),
            onStartSession: { session in
                router.presentActiveWorkout(sessionID: session.id)
            }
        )
    }

    private var libraryTab: some View {
        ExerciseLibraryView(
            vm: ExerciseLibraryViewModel(
                exercisesRepo: container.exerciseRepository
            ),
            exercisesRepo: container.exerciseRepository
        )
    }

    private func placeholderTab(title: String, systemImage: String) -> some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.App.onSurface.opacity(0.3))
                Text(title)
                    .font(Font.App.headlineLg)
                    .foregroundStyle(Color.App.onSurface)
                Text("Coming soon")
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
    }
}

private struct ActiveWorkoutPlaceholderView: View {
    let sessionID: UUID
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()
            VStack(spacing: Spacing.lg) {
                SectionLabel(text: "Active Session")
                Text(sessionID.uuidString)
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                KineticButton(title: "Finish", action: onFinish)
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

#Preview {
    let mc = try! ModelContainer.makePreview()
    RootView()
        .environment(DIContainer(modelContext: mc.mainContext))
        .environment(AppRouter())
        .modelContainer(mc)
        .kineticTheme()
}
