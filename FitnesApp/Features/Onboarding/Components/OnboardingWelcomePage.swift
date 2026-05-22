import SwiftUI

struct OnboardingWelcomePage: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            eyebrow: "onboarding.welcome.eyebrow",
            title: "onboarding.welcome.title",
            bodyText: "onboarding.welcome.body",
            ctaTitle: "onboarding.welcome.cta",
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
    OnboardingWelcomePage(onContinue: {})
        .kineticTheme()
}
