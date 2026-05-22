import SwiftUI

struct OnboardingPageScaffold<Hero: View>: View {
    let progressIndex: Int
    let totalSteps: Int
    let eyebrow: LocalizedStringResource
    let title: LocalizedStringResource
    let bodyText: LocalizedStringResource
    let ctaTitle: LocalizedStringResource
    let onSkip: () -> Void
    let onContinue: () -> Void
    @ViewBuilder let hero: () -> Hero

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: Spacing.lg)
            hero()
                .frame(maxWidth: .infinity)
            Spacer(minLength: Spacing.lg)
            content
            cta
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack {
            ProgressDots(total: totalSteps, completed: progressIndex + 1)
            Spacer()
            Button(action: onSkip) {
                Text("onboarding.skip")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.6))
                    .tracking(0.8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionLabel(text: String(localized: eyebrow))
            Text(title)
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
                .multilineTextAlignment(.leading)
            Text(bodyText)
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.6))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
    }

    private var cta: some View {
        KineticButton(
            title: String(localized: ctaTitle),
            trailingSystemName: "arrow.right",
            action: onContinue
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }
}
