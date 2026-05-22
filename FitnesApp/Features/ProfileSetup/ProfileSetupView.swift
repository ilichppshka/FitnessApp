import SwiftUI

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
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        header
                        avatar
                        nameSection
                        weightSection
                        mascotSection
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(Font.App.bodyMd)
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.lg)
                }

                cta
            }
        }
        .task {
            await requestNotificationsOnce()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "profileSetup.eyebrow"))
            Text("profileSetup.title")
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
            Text("profileSetup.body")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.6))
        }
    }

    private var avatar: some View {
        HStack {
            Spacer()
            AvatarCircle(
                initial: avatarInitial,
                size: 96,
                overlayBadge: Image(systemName: viewModel.selectedMascot.systemImage)
            )
            Spacer()
        }
    }

    private var avatarInitial: String {
        if let first = viewModel.trimmedName.first {
            return String(first).uppercased()
        }
        return "K"
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "profileSetup.name.label"))
            GhostInputField(
                placeholder: String(localized: "profileSetup.name.placeholder"),
                text: $viewModel.name
            )
        }
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "profileSetup.weight.label"))
            HStack(spacing: Spacing.md) {
                StepperButton(
                    kind: .minus,
                    isEnabled: viewModel.canDecrementWeight,
                    action: viewModel.decrementWeight
                )

                weightValue

                StepperButton(
                    kind: .plus,
                    isEnabled: viewModel.canIncrementWeight,
                    action: viewModel.incrementWeight
                )
            }
        }
    }

    private var weightValue: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text(weightDisplay)
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
            Text("profileSetup.weight.unit")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerHigh)
        )
    }

    private var weightDisplay: String {
        if viewModel.bodyWeightKg.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(viewModel.bodyWeightKg))
        }
        return String(format: "%.1f", viewModel.bodyWeightKg)
    }

    private var mascotSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "profileSetup.mascot.label"))
            MascotPickerGrid(selection: $viewModel.selectedMascot)
        }
    }

    private var cta: some View {
        KineticButton(
            title: String(localized: "profileSetup.cta"),
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
