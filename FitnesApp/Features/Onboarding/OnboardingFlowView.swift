import SwiftData
import SwiftUI

struct OnboardingFlowView: View {
    @Environment(DIContainer.self) private var container
    @State private var viewModel = OnboardingFlowViewModel()
    let onComplete: @MainActor () -> Void

    private var totalSteps: Int { OnboardingFlowViewModel.Step.allCases.count }
    private var currentIndex: Int { viewModel.currentStep.rawValue }

    var body: some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                TabView(selection: $viewModel.currentStep) {
                    OnboardingWelcomePage(onContinue: viewModel.next)
                        .tag(OnboardingFlowViewModel.Step.welcome)

                    OnboardingLogPage(onContinue: viewModel.next)
                        .tag(OnboardingFlowViewModel.Step.log)

                    OnboardingAnalyzePage(onContinue: viewModel.next)
                        .tag(OnboardingFlowViewModel.Step.analyze)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.container, edges: .bottom)
                .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showsProfileSetup) {
            ProfileSetupView(
                users: container.userRepository,
                notifications: container.notificationService,
                onComplete: onComplete
            )
        }
    }

    private var header: some View {
        HStack {
            ProgressPillBar(total: totalSteps, currentIndex: currentIndex)
            Spacer()
            Button(action: viewModel.skip) {
                Text(LocalizedStringResource("onboarding.skip", table: "Onboarding"))
                    .kineticText(.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }
}

#Preview("Onboarding flow") {
    // swiftlint:disable:next force_try
    let mc = try! ModelContainer.makePreview()
    OnboardingFlowView(onComplete: {})
        .environment(DIContainer(modelContext: mc.mainContext))
        .modelContainer(mc)
        .kineticTheme()
}
