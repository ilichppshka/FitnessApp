import SwiftData
import SwiftUI

struct ExerciseDetailSheet: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                title
                muscleGroupChips
                animationPlaceholder
                descriptionSection(
                    label: String(localized: "library.detail.section.start"),
                    body: exercise.descriptionStart
                )
                descriptionSection(
                    label: String(localized: "library.detail.section.execution"),
                    body: exercise.descriptionExecution
                )
                descriptionSection(
                    label: String(localized: "library.detail.section.errors"),
                    body: exercise.descriptionErrors
                )
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color.App.surface.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var title: some View {
        Text(exercise.name)
            .font(Font.App.headlineLg)
            .foregroundStyle(Color.App.onSurface)
    }

    private var muscleGroupChips: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "library.detail.section.muscles"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(exercise.muscleGroups, id: \.id) { group in
                        Chip(title: group.name, style: .subtle)
                    }
                }
            }
        }
    }

    private var animationPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radii.lg)
                .fill(Color.App.surfaceContainerLow)
            VStack(spacing: Spacing.sm) {
                Image(systemName: "play.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.App.primary.opacity(0.6))
                Text("library.detail.animation.placeholder")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func descriptionSection(label: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: label)
            Text(body)
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Exercise Detail Sheet") {
    let mc = try! ModelContainer.makePreview()
    try? DataSeeder.seedIfNeeded(mc.mainContext)
    let exercises = (try? mc.mainContext.fetch(FetchDescriptor<Exercise>())) ?? []
    return Group {
        if let exercise = exercises.first {
            Color.App.surface
                .ignoresSafeArea()
                .sheet(isPresented: .constant(true)) {
                    ExerciseDetailSheet(exercise: exercise)
                }
        } else {
            Text("No seeded exercises")
        }
    }
    .modelContainer(mc)
    .kineticTheme()
}
#endif
