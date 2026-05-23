import SwiftData
import SwiftUI
import UIKit

struct ExerciseLibraryView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ExerciseLibraryViewModel

    init(repository: any ExerciseRepository) {
        _viewModel = State(initialValue: ExerciseLibraryViewModel(repository: repository))
    }

    var body: some View {
        @Bindable var bindableRouter = router

        ZStack {
            Color.App.surface.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                header
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                searchField
                    .padding(.horizontal, Spacing.md)

                muscleChipsBar

                content
            }
        }
        .task {
            await viewModel.loadInitial()
        }
        .task(id: viewModel.searchTrigger) {
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            await viewModel.reload()
        }
        .sheet(
            isPresented: Binding(
                get: { bindableRouter.presentedExerciseDetailID != nil },
                set: { if !$0 { bindableRouter.presentedExerciseDetailID = nil } }
            )
        ) {
            if let id = router.presentedExerciseDetailID,
                let exercise = viewModel.exercise(id: id)
            {
                ExerciseDetailSheet(exercise: exercise)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            ScreenHeader(
                label: String(localized: "library.label"),
                title: String(localized: "library.title"),
                accent: "\(viewModel.totalCount)"
            )
            Spacer()
            IconChip(
                systemName: "line.3.horizontal.decrease",
                action: {}
            )
            .accessibilityLabel(Text("library.filter.button.a11y"))
        }
    }

    private var searchField: some View {
        SearchField(
            placeholder: String(localized: "library.search.placeholder \(viewModel.totalCount)"),
            text: $viewModel.searchQuery,
            trailingMeta: "\(viewModel.exercises.count)"
        )
    }

    private var muscleChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                Chip(
                    title: String(localized: "library.filter.all"),
                    style: viewModel.selectedMuscleGroupID == nil ? .selected : .outline,
                    action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.selectGroup(nil)
                    }
                )

                ForEach(viewModel.muscleGroups) { group in
                    Chip(
                        title: group.name,
                        style: viewModel.selectedMuscleGroupID == group.id ? .selected : .outline,
                        action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.selectGroup(group.id)
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.exercises.isEmpty && !viewModel.isLoading {
            emptyState
        } else {
            exerciseList
        }
    }

    private var exerciseList: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(viewModel.exercises, id: \.id) { exercise in
                    ExerciseListItem(
                        title: NSLocalizedString("exercise.\(exercise.slug).name", tableName: "Exercises", comment: ""),
                        subtitle: (exercise.primaryMuscleGroups + exercise.secondaryMuscleGroups)
                            .map { NSLocalizedString("muscle.\($0.slug)", tableName: "Exercises", comment: "") }
                            .joined(separator: " · "),
                        onTap: { router.presentedExerciseDetailID = exercise.id }
                    )
                    .accessibilityHint(Text("library.row.hint.a11y"))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Color.App.onSurface.opacity(0.3))
            Text("library.empty.title")
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
            Text("library.empty.subtitle")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("Exercise Library") {
    let mc = try! ModelContainer.makePreview()
    try? DataSeeder.seedIfNeeded(mc.mainContext)
    return ExerciseLibraryView(
        repository: SwiftDataExerciseRepository(context: mc.mainContext)
    )
    .modelContainer(mc)
    .environment(AppRouter())
    .kineticTheme()
}
#endif
