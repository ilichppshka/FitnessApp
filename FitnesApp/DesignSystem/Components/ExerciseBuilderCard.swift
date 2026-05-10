import SwiftUI

struct ExerciseBuilderSet: Identifiable {
    let id: UUID
    var weight: String
    var reps: String

    init(id: UUID = UUID(), weight: String, reps: String) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}

struct ExerciseBuilderCard: View {
    let index: Int
    let title: String
    let subtitle: String
    @Binding var isExpanded: Bool
    @Binding var sets: [ExerciseBuilderSet]
    @Binding var restText: String
    var collapsedSummary: String?
    var onAddSet: () -> Void
    var onRemoveSet: (UUID) -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            header

            if isExpanded {
                Divider().background(Color.App.outlineVariant.opacity(0.2))
                setsTable
                addSetButton
                RestRow(label: "Rest between sets", timeText: restText, action: {})
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerHigh)
        )
    }

    private var header: some View {
        HStack(spacing: Spacing.md) {
            Badge(text: "\(index)", style: isExpanded ? .filled : .outlined, size: 28)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.App.onSurface)
                    .lineLimit(1)
                Text(subtitle)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if !isExpanded, let collapsedSummary {
                Text(collapsedSummary)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.7))
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
    }

    private var setsTable: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                Text("SET")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .frame(width: 24, alignment: .leading)
                Text("WEIGHT")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .frame(maxWidth: .infinity)
                Text("REPS")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .frame(maxWidth: .infinity)
                Spacer().frame(width: 28)
            }

            ForEach($sets) { $set in
                SetRow(
                    index: (sets.firstIndex(where: { $0.id == set.id }) ?? 0) + 1,
                    weight: $set.weight,
                    reps: $set.reps,
                    onRemove: { onRemoveSet(set.id) }
                )
            }
        }
    }

    private var addSetButton: some View {
        Button(action: onAddSet) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                Text("Add set")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color.App.onSurface.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Radii.sm)
                    .strokeBorder(
                        Color.App.outlineVariant.opacity(0.4),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Exercise Builder Card") {
    @Previewable @State var expanded = true
    @Previewable @State var collapsed = false
    @Previewable @State var rest = "02:00"
    @Previewable @State var sets: [ExerciseBuilderSet] = [
        ExerciseBuilderSet(weight: "60", reps: "12"),
        ExerciseBuilderSet(weight: "70", reps: "10"),
        ExerciseBuilderSet(weight: "75", reps: "8"),
        ExerciseBuilderSet(weight: "75", reps: "8")
    ]

    return ScrollView {
        VStack(spacing: Spacing.md) {
            ExerciseBuilderCard(
                index: 1,
                title: "Barbell Bench Press",
                subtitle: "Chest · Triceps · Front delts",
                isExpanded: $expanded,
                sets: $sets,
                restText: $rest,
                onAddSet: {
                    sets.append(ExerciseBuilderSet(weight: "", reps: ""))
                },
                onRemoveSet: { id in
                    sets.removeAll { $0.id == id }
                }
            )

            ExerciseBuilderCard(
                index: 2,
                title: "Incline Dumbbell Press",
                subtitle: "Upper chest · Front delts",
                isExpanded: $collapsed,
                sets: .constant([]),
                restText: .constant("02:00"),
                collapsedSummary: "4 × 10–12",
                onAddSet: {},
                onRemoveSet: { _ in }
            )
        }
        .padding(Spacing.lg)
    }
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
