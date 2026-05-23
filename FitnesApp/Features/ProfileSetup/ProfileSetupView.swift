import SwiftData
import SwiftUI
import UIKit

struct ProfileSetupView: View {
    @AppStorage("notificationPromptShown") private var notificationPromptShown = false
    @State private var viewModel: ProfileSetupViewModel

    init(
        users: any UserRepository,
        notifications: any NotificationScheduling,
        onComplete: @escaping @MainActor () -> Void
    ) {
        _viewModel = State(
            initialValue: ProfileSetupViewModel(
                users: users,
                notifications: notifications,
                onComplete: onComplete
            )
        )
    }

    var body: some View {
        ZStack {
            Color.App.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        hero
                        introCopy
                        VStack(alignment: .leading, spacing: Spacing.xl) {
                            nameSection
                            weightSection
                            mascotSection
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(Font.App.bodyMd)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }

                cta
            }
        }
        .task {
            await requestNotificationsOnce()
        }
    }

    private var hero: some View {
        VStack(spacing: Spacing.lg) {
            Text(LocalizedStringResource("profileSetup.brand", table: "Onboarding"))
                .font(Font.App.labelSm)
                .tracking(1.6)
                .foregroundStyle(Color.App.onSurface.opacity(0.55))

            ProfileAvatarHero(
                initial: avatarInitial,
                mascotSystemImage: viewModel.selectedMascot.systemImage
            )
        }
    }

    private var introCopy: some View {
        VStack(spacing: Spacing.sm) {
            Text(LocalizedStringResource("profileSetup.eyebrow", table: "Onboarding"))
                .font(Font.App.labelSm)
                .tracking(1.2)
                .foregroundStyle(Color.App.primary)

            Text(LocalizedStringResource("profileSetup.title", table: "Onboarding"))
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
                .multilineTextAlignment(.center)

            Text(LocalizedStringResource("profileSetup.body", table: "Onboarding"))
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.md)
        }
    }

    private var avatarInitial: String {
        if let first = viewModel.trimmedName.first {
            return String(first).uppercased()
        }
        return "A"
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            labelRow(label: LocalizedStringResource("profileSetup.name.label", table: "Onboarding"), hint: LocalizedStringResource("profileSetup.name.hint", table: "Onboarding"))
            outlinedNameField
        }
    }

    private var outlinedNameField: some View {
        OutlinedTextField(
            placeholder: String(localized: "profileSetup.name.placeholder", table: "Onboarding"),
            text: $viewModel.name
        )
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            labelRow(label: LocalizedStringResource("profileSetup.weight.label", table: "Onboarding"), hint: nil)
            weightRow
        }
    }

    private var weightRow: some View {
        HStack(spacing: Spacing.md) {
            weightDisplay
            Spacer(minLength: Spacing.md)
            HStack(spacing: Spacing.sm) {
                inlineStepper(kind: .minus, isEnabled: viewModel.canDecrementWeight, action: viewModel.decrementWeight)
                inlineStepper(kind: .plus, isEnabled: viewModel.canIncrementWeight, action: viewModel.incrementWeight)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerHigh)
        )
    }

    private var weightDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(weightValueText)
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.22), value: viewModel.bodyWeightKg)
            Text(LocalizedStringResource("profileSetup.weight.unit", table: "Onboarding"))
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
        }
    }

    private var weightValueText: String {
        if viewModel.bodyWeightKg.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(viewModel.bodyWeightKg))
        }
        return String(format: "%.1f", viewModel.bodyWeightKg)
    }

    private func inlineStepper(
        kind: StepperKind,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Image(systemName: kind.systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.App.onSurface)
                .frame(width: 40, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.App.surface)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
    }

    private var mascotSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            labelRow(label: LocalizedStringResource("profileSetup.mascot.label", table: "Onboarding"), hint: LocalizedStringResource("profileSetup.mascot.hint", table: "Onboarding"))
            MascotPickerGrid(selection: $viewModel.selectedMascot)
        }
    }

    private func labelRow(
        label: LocalizedStringResource,
        hint: LocalizedStringResource?
    ) -> some View {
        HStack {
            SectionLabel(text: String(localized: label))
            Spacer()
            if let hint {
                Text(hint)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.4))
                    .tracking(0.8)
            }
        }
    }

    private var cta: some View {
        KineticButton(
            title: String(localized: "profileSetup.cta", table: "Onboarding"),
            isEnabled: viewModel.canSave,
            trailingSystemName: "arrow.right",
            action: { Task { await viewModel.save() } }
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xl)
        .background(Color.App.surface)
    }

    private func requestNotificationsOnce() async {
        guard !notificationPromptShown else { return }
        notificationPromptShown = true
        await viewModel.requestNotificationAuthorization()
    }
}

private struct OutlinedTextField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(Font.App.titleLg)
            .foregroundStyle(Color.App.onSurface)
            .tint(Color.App.primary)
            .focused($isFocused)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radii.md)
                    .fill(Color.App.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .strokeBorder(
                        isFocused ? Color.App.primary : Color.App.outlineVariant.opacity(0.6),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

#if DEBUG
private final class PreviewNotificationScheduling: NotificationScheduling, @unchecked Sendable {
    func requestAuthorizationIfNeeded() async throws -> Bool { true }
    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws {}
    func cancelRestEnd(sessionID: UUID) async {}
}

#Preview("Profile Setup") {
    let mc = try! ModelContainer.makePreview()
    ProfileSetupView(
        users: SwiftDataUserRepository(context: mc.mainContext),
        notifications: PreviewNotificationScheduling(),
        onComplete: {}
    )
    .modelContainer(mc)
    .kineticTheme()
}
#endif
