import Foundation
import SwiftData

protocol WorkoutRepository {
    func plans(includeDrafts: Bool) async throws -> [WorkoutPlan]
    func find(id: UUID) async throws -> WorkoutPlan?
    func scheduled(weekday: Int) async throws -> [WorkoutPlan]

    func createDraft() async throws -> WorkoutPlan
    func upsert(_ planID: UUID, mutate: @MainActor (WorkoutPlan) -> Void) async throws
    func publish(_ planID: UUID) async throws
    func remove(_ planID: UUID) async throws

    func addExercise(_ exerciseID: UUID, to planID: UUID) async throws -> PlanExercise
    func removeExercise(_ planExerciseID: UUID) async throws
    func reorder(planID: UUID, from: IndexSet, to: Int) async throws
    func setPlanSets(_ sets: [PlanSetDraft], for planExerciseID: UUID) async throws
    func setRest(_ duration: TimeInterval, for planExerciseID: UUID) async throws
}

final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func plans(includeDrafts: Bool) async throws -> [WorkoutPlan] {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            sortBy: [SortDescriptor(\.name)]
        )
        let all = try context.fetch(descriptor)
        return includeDrafts ? all : all.filter { !$0.isDraft }
    }

    func find(id: UUID) async throws -> WorkoutPlan? {
        var descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func scheduled(weekday: Int) async throws -> [WorkoutPlan] {
        let all = try context.fetch(FetchDescriptor<WorkoutPlan>())
        return all.filter { $0.scheduledWeekdays.contains(weekday) && !$0.isDraft }
            .sorted { $0.name < $1.name }
    }

    func createDraft() async throws -> WorkoutPlan {
        let draft = WorkoutPlan(name: "New Workout", isDraft: true)
        context.insert(draft)
        try context.save()
        return draft
    }

    func upsert(_ planID: UUID, mutate: @MainActor (WorkoutPlan) -> Void) async throws {
        guard let plan = try await find(id: planID) else { return }
        mutate(plan)
        plan.updatedAt = .now
        try context.save()
    }

    func publish(_ planID: UUID) async throws {
        guard let plan = try await find(id: planID) else { return }
        plan.isDraft = false
        plan.updatedAt = .now
        try context.save()
    }

    func remove(_ planID: UUID) async throws {
        guard let plan = try await find(id: planID) else { return }
        context.delete(plan)
        try context.save()
    }

    func addExercise(_ exerciseID: UUID, to planID: UUID) async throws -> PlanExercise {
        guard let plan = try await find(id: planID) else {
            throw DataError.persistence("WorkoutPlan not found: \(planID)")
        }
        guard let exercise = try fetchExercise(id: exerciseID) else {
            throw DataError.exerciseNotFound(id: exerciseID)
        }
        let nextOrder = (plan.planExercises.map(\.order).max() ?? -1) + 1
        let planExercise = PlanExercise(
            plan: plan,
            exercise: exercise,
            order: nextOrder,
            restDuration: 90,
            targetRepMin: 8,
            targetRepMax: 12
        )
        context.insert(planExercise)
        let defaultSet = PlanSet(planExercise: planExercise, order: 0, targetReps: 8)
        context.insert(defaultSet)
        plan.updatedAt = .now
        try context.save()
        return planExercise
    }

    func removeExercise(_ planExerciseID: UUID) async throws {
        guard let pe = try fetchPlanExercise(id: planExerciseID) else { return }
        pe.plan?.updatedAt = .now
        context.delete(pe)
        try context.save()
    }

    func reorder(planID: UUID, from: IndexSet, to: Int) async throws {
        guard let plan = try await find(id: planID) else { return }
        var ordered = plan.planExercises.sorted { $0.order < $1.order }
        ordered.move(fromOffsets: from, toOffset: to)
        for (index, item) in ordered.enumerated() {
            item.order = index
        }
        plan.updatedAt = .now
        try context.save()
    }

    func setPlanSets(_ sets: [PlanSetDraft], for planExerciseID: UUID) async throws {
        guard let pe = try fetchPlanExercise(id: planExerciseID) else { return }
        for existing in pe.planSets {
            context.delete(existing)
        }
        for draft in sets {
            let set = PlanSet(planExercise: pe, order: draft.order, targetReps: draft.targetReps)
            if let weight = draft.targetWeight { set.targetWeight = weight }
            context.insert(set)
        }
        pe.plan?.updatedAt = .now
        try context.save()
    }

    func setRest(_ duration: TimeInterval, for planExerciseID: UUID) async throws {
        guard let pe = try fetchPlanExercise(id: planExerciseID) else { return }
        pe.restDuration = duration
        pe.plan?.updatedAt = .now
        try context.save()
    }

    // MARK: - Private helpers

    private func fetchExercise(id: UUID) throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func fetchPlanExercise(id: UUID) throws -> PlanExercise? {
        var descriptor = FetchDescriptor<PlanExercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
