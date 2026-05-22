import SwiftUI

struct OnboardingWelcomePage: View {
    let progressIndex: Int
    let totalSteps: Int
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            progressIndex: progressIndex,
            totalSteps: totalSteps,
            eyebrow: "onboarding.welcome.eyebrow",
            title: "onboarding.welcome.title",
            bodyText: "onboarding.welcome.body",
            ctaTitle: "onboarding.welcome.cta",
            onSkip: onSkip,
            onContinue: onContinue
        ) {
            heroCircle
        }
    }

    private var heroCircle: some View {
        ZStack {
            Circle()
                .fill(Color.App.primary)
                .frame(width: 180, height: 180)
                .neonGlow(radius: 28, opacity: 0.55)

            Image("KineticLogo")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
        }
    }
}

#Preview("Welcome") {
    OnboardingWelcomePage(
        progressIndex: 0,
        totalSteps: 3,
        onSkip: {},
        onContinue: {}
    )
    .kineticTheme()
}
