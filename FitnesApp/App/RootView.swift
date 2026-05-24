import SwiftData
import SwiftUI

struct RootView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some View {
        Group {
            if onboardingCompleted {
                MainTabsView()
            } else {
                OnboardingFlowView(onComplete: { onboardingCompleted = true })
            }
        }
        .animation(.easeInOut, value: onboardingCompleted)
    }
}

private struct MainTabsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(DIContainer.self) private var container

    var body: some View {
        @Bindable var bindableRouter = router

        TabView(selection: $bindableRouter.selectedTab) {
            DashboardView(userRepository: container.userRepository)
                .tag(AppRouter.Tab.dashboard)
                .tabItem { Label("tab.home", systemImage: "house.fill") }

            ExerciseLibraryView(repository: container.exerciseRepository)
                .tag(AppRouter.Tab.library)
                .tabItem { Label("tab.exercises", systemImage: "dumbbell.fill") }

            placeholderTab(title: "tab.progress", systemImage: "chart.bar.fill")
                .tag(AppRouter.Tab.progress)
                .tabItem { Label("tab.progress", systemImage: "chart.bar.fill") }

            placeholderTab(title: "tab.settings", systemImage: "gearshape.fill")
                .tag(AppRouter.Tab.settings)
                .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
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

    private func placeholderTab(title: LocalizedStringKey, systemImage: String) -> some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.App.onSurface.opacity(0.3))
                Text(title)
                    .font(Font.App.headlineLg)
                    .foregroundStyle(Color.App.onSurface)
                Text("placeholder.coming_soon")
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
                SectionLabel(text: String(localized: "workout.active_session"))
                Text(sessionID.uuidString)
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                KineticButton(title: String(localized: "common.finish"), action: onFinish)
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let mc = try! ModelContainer.makePreview()
    RootView()
        .environment(DIContainer(modelContext: mc.mainContext))
        .environment(AppRouter())
        .modelContainer(mc)
        .kineticTheme()
}
