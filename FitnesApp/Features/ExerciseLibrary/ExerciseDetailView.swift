import SwiftData
import SwiftUI

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseDetailViewModel
    private let exerciseID: UUID

    init(exerciseID: UUID, repository: any ExerciseRepository) {
        self.exerciseID = exerciseID
        _viewModel = State(initialValue: ExerciseDetailViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                headerBar
                if let exercise = viewModel.exercise {
                    heroBlock(exercise)
                        .padding(.horizontal, Spacing.md)
                    AnimationPlayerCard(animationAssetName: exercise.animationAssetName)
                        .padding(.horizontal, Spacing.md)
                    MuscleGroupChipsSection(
                        primaryNames: exercise.primaryMuscles.map { localizedMuscle($0.slug) },
                        secondaryNames: exercise.secondaryMuscles.map { localizedMuscle($0.slug) }
                    )
                    .padding(.horizontal, Spacing.md)
                    executionContent(exercise)
                        .padding(.bottom, Spacing.xl)
                } else if viewModel.isLoading {
                    loadingView
                } else if let msg = viewModel.errorMessage {
                    errorView(msg)
                }
            }
            .padding(.top, Spacing.md)
        }
        .background(Color.App.surface.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            bottomDock
        }
        .task {
            await viewModel.load(id: exerciseID)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            HStack {
                Spacer()
                eyebrowText
                Spacer()
            }
            HStack {
                Spacer()
                IconChip(systemName: "xmark", action: { dismiss() })
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private var eyebrowText: some View {
        let base = String(localized: "library.detail.eyebrow")
        let suffix = viewModel.exercise?.primaryMuscles.first
            .map { " · \(localizedMuscle($0.slug).uppercased())" } ?? ""
        return Text("\(base)\(suffix)")
            .font(Font.App.labelSm)
            .tracking(0.8)
            .foregroundStyle(Color.App.onSurface.opacity(0.4))
    }

    // MARK: - Hero

    private func heroBlock(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Chip(title: exercise.equipment.localizedName, style: .selected)
                difficultyIndicator(exercise.difficulty)
            }
            Text(NSLocalizedString("exercise.\(exercise.slug).name", tableName: "Exercises", comment: ""))
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
        }
    }

    private func difficultyIndicator(_ difficulty: ExerciseDifficulty) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.App.primary)
            Text(difficulty.localizedName)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Capsule().fill(Color.App.surfaceContainerLow))
        .overlay(Capsule().strokeBorder(Color.App.outlineVariant.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Execution sections

    @ViewBuilder
    private func executionContent(_ exercise: Exercise) -> some View {
        let sorted = exercise.executionSteps.sorted { $0.order < $1.order }
        let setupStep = sorted.first { $0.key == "setup" }
        let execSteps = sorted.filter { $0.key != "setup" }

        VStack(alignment: .leading, spacing: Spacing.xl) {
            if let step = setupStep {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionLabel(text: String(localized: "library.detail.section.start"))
                    Text(NSLocalizedString("exercise.\(exercise.slug).step.\(step.key).body", tableName: "Exercises", comment: ""))
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Spacing.md)
            }

            if !execSteps.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SectionLabel(text: String(localized: "library.detail.section.execution"))
                        .padding(.horizontal, Spacing.md)
                    ForEach(Array(execSteps.enumerated()), id: \.element.id) { idx, step in
                        ExecutionStepRow(
                            number: idx + 1,
                            title: NSLocalizedString(
                                "exercise.\(exercise.slug).step.\(step.key).title",
                                tableName: "Exercises",
                                comment: ""
                            ),
                            text: NSLocalizedString(
                                "exercise.\(exercise.slug).step.\(step.key).body",
                                tableName: "Exercises",
                                comment: ""
                            )
                        )
                        .padding(.horizontal, Spacing.md)
                    }
                }
            }

            if !exercise.mistakeKeys.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SectionLabel(text: String(localized: "library.detail.section.errors"))
                        .padding(.horizontal, Spacing.md)
                    ForEach(exercise.mistakeKeys, id: \.self) { key in
                        MistakeBulletRow(
                            text: NSLocalizedString("exercise.\(exercise.slug).mistake.\(key)", tableName: "Exercises", comment: "")
                        )
                        .padding(.horizontal, Spacing.md)
                    }
                }
            }
        }
    }

    // MARK: - Bottom dock

    private var bottomDock: some View {
        HStack(spacing: Spacing.md) {
            let isFav = viewModel.exercise?.isFavorite == true
            Button {
                Task { await viewModel.toggleFavorite() }
            } label: {
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isFav ? Color.App.primary : Color.App.onSurface.opacity(0.6))
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.App.surfaceContainerHigh))
                    .overlay(Circle().strokeBorder(Color.App.outlineVariant.opacity(0.3), lineWidth: 1))
            }
            .accessibilityLabel(isFav
                ? String(localized: "library.detail.dock.favorite.remove")
                : String(localized: "library.detail.dock.favorite.add"))

            KineticButton(title: String(localized: "library.detail.dock.addToWorkout")) {}
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
        .padding(.top, Spacing.sm)
        .background(
            Color.App.surface
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .top) {
                    Divider().opacity(0.3)
                }
        )
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, minHeight: 200)
            .tint(Color.App.primary)
    }

    private func errorView(_ message: String) -> some View {
        Text(message)
            .font(Font.App.bodyMd)
            .foregroundStyle(Color.App.onSurface.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(Spacing.xl)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func localizedMuscle(_ slug: String) -> String {
        NSLocalizedString("muscle.\(slug)", tableName: "Exercises", comment: "")
    }
}

// MARK: - Equipment localization

extension ExerciseEquipment {
    var localizedName: String {
        switch self {
        case .barbell: String(localized: "exercise.equipment.barbell")
        case .dumbbell: String(localized: "exercise.equipment.dumbbell")
        case .bodyweight: String(localized: "exercise.equipment.bodyweight")
        case .cable: String(localized: "exercise.equipment.cable")
        case .machine: String(localized: "exercise.equipment.machine")
        case .kettlebell: String(localized: "exercise.equipment.kettlebell")
        case .band: String(localized: "exercise.equipment.band")
        case .other: String(localized: "exercise.equipment.other")
        }
    }
}

// MARK: - Difficulty localization

extension ExerciseDifficulty {
    var localizedName: String {
        switch self {
        case .beginner: String(localized: "exercise.difficulty.beginner")
        case .intermediate: String(localized: "exercise.difficulty.intermediate")
        case .advanced: String(localized: "exercise.difficulty.advanced")
        }
    }
}

#if DEBUG
#Preview("Exercise Detail View") {
    // swiftlint:disable:next force_try
    let mc = try! ModelContainer.makePreview()
    try? DataSeeder.seedIfNeeded(mc.mainContext)
    let exercises = (try? mc.mainContext.fetch(FetchDescriptor<Exercise>())) ?? []
    return Group {
        if let exercise = exercises.first {
            Color.App.surface
                .ignoresSafeArea()
                .sheet(isPresented: .constant(true)) {
                    ExerciseDetailView(
                        exerciseID: exercise.id,
                        repository: SwiftDataExerciseRepository(context: mc.mainContext)
                    )
                }
        } else {
            Text("No seeded exercises")
        }
    }
    .modelContainer(mc)
    .kineticTheme()
}
#endif
