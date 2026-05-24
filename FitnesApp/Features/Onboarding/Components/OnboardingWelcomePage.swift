import SwiftUI

struct OnboardingWelcomePage: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageScaffold(
            eyebrow: LocalizedStringResource("onboarding.welcome.eyebrow", table: "Onboarding"),
            title: LocalizedStringResource("onboarding.welcome.title", table: "Onboarding"),
            bodyText: LocalizedStringResource("onboarding.welcome.body", table: "Onboarding"),
            ctaTitle: LocalizedStringResource("onboarding.welcome.cta", table: "Onboarding"),
            onContinue: onContinue
        ) {
            heroCircle
        }
    }

    private var heroCircle: some View {
        let circleDiameter: CGFloat = 180
        let logoDiameter: CGFloat = 110
        return ZStack {
            Circle()
                .fill(Color.App.primary)
                .frame(width: circleDiameter, height: circleDiameter)
                .neonGlow(radius: 28, opacity: 0.55)

            Image("KineticLogo")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: logoDiameter, height: logoDiameter)
        }
    }
}

#Preview("Welcome") {
    OnboardingWelcomePage(onContinue: {})
        .kineticTheme()
}
