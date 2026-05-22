import SwiftData
import SwiftUI

struct OnboardingFlowView: View {
    @Environment(DIContainer.self) private var container
    @State private var viewModel = OnboardingFlowViewModel()
    let onComplete: @MainActor () -> Void

    private var totalSteps: Int { OnboardingFlowViewModel.Step.allCases.count }

    var body: some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()

            TabView(selection: $viewModel.currentStep) {
                OnboardingWelcomePage(
                    progressIndex: 0,
                    totalSteps: totalSteps,
                    onSkip: viewModel.skip,
                    onContinue: viewModel.next
                )
                .tag(OnboardingFlowViewModel.Step.welcome)

                OnboardingLogPage(
                    progressIndex: 1,
                    totalSteps: totalSteps,
                    onSkip: viewModel.skip,
                    onContinue: viewModel.next
                )
                .tag(OnboardingFlowViewModel.Step.log)

                OnboardingAnalyzePage(
                    progressIndex: 2,
                    totalSteps: totalSteps,
                    onSkip: viewModel.skip,
                    onContinue: viewModel.next
                )
                .tag(OnboardingFlowViewModel.Step.analyze)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)
        }
        .fullScreenCover(isPresented: $viewModel.showsProfileSetup) {
            ProfileSetupView(
                users: container.userRepository,
                notifications: container.notificationService,
                onComplete: onComplete
            )
        }
    }
}

#Preview("Onboarding flow") {
    let mc = try! ModelContainer.makePreview()
    OnboardingFlowView(onComplete: {})
        .environment(DIContainer(modelContext: mc.mainContext))
        .modelContainer(mc)
        .kineticTheme()
}
