import Foundation
import SwiftData

protocol WorkoutRepository {
    func all() async throws -> [WorkoutPlan]
    func find(id: UUID) async throws -> WorkoutPlan?
    func upsert(_ plan: WorkoutPlan) async throws
    func delete(_ plan: WorkoutPlan) async throws
    func addExercise(_ exercise: Exercise, to plan: WorkoutPlan, targetSets: Int, restDuration: TimeInterval) async throws
    func remove(_ planExercise: PlanExercise) async throws
    func reorder(plan: WorkoutPlan, from source: IndexSet, to destination: Int) async throws
}

final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() async throws -> [WorkoutPlan] {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func find(id: UUID) async throws -> WorkoutPlan? {
        var descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func upsert(_ plan: WorkoutPlan) async throws {
        if plan.modelContext == nil {
            context.insert(plan)
        }
        try context.save()
    }

    func delete(_ plan: WorkoutPlan) async throws {
        context.delete(plan)
        try context.save()
    }

    func addExercise(
        _ exercise: Exercise,
        to plan: WorkoutPlan,
        targetSets: Int,
        restDuration: TimeInterval
    ) async throws {
        let nextOrder = (plan.planExercises.map(\.order).max() ?? -1) + 1
        let planExercise = PlanExercise(
            plan: plan,
            exercise: exercise,
            order: nextOrder,
            targetSets: targetSets,
            restDuration: restDuration
        )
        context.insert(planExercise)
        try context.save()
    }

    func remove(_ planExercise: PlanExercise) async throws {
        context.delete(planExercise)
        try context.save()
    }

    func reorder(plan: WorkoutPlan, from source: IndexSet, to destination: Int) async throws {
        var ordered = plan.planExercises.sorted { $0.order < $1.order }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, item) in ordered.enumerated() {
            item.order = index
        }
        try context.save()
    }
}
