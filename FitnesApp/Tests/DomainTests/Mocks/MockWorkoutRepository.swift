@testable import FitnesApp
import Foundation

@MainActor
final class MockWorkoutRepository: WorkoutRepository {
    var plansResult: [WorkoutPlan] = []
    var findResult: WorkoutPlan?

    private(set) var plansCalls: [Bool] = []
    private(set) var findCalls: [UUID] = []
    private(set) var createDraftCalled = false

    func plans(includeDrafts: Bool) async throws -> [WorkoutPlan] {
        plansCalls.append(includeDrafts)
        return includeDrafts ? plansResult : plansResult.filter { !$0.isDraft }
    }

    func find(id: UUID) async throws -> WorkoutPlan? {
        findCalls.append(id)
        return findResult
    }

    func scheduled(weekday: Int) async throws -> [WorkoutPlan] {
        plansResult.filter { $0.scheduledWeekdays.contains(weekday) && !$0.isDraft }
    }

    func createDraft() async throws -> WorkoutPlan {
        createDraftCalled = true
        return WorkoutPlan(name: "Draft", isDraft: true)
    }

    func upsert(_ planID: UUID, mutate: @MainActor (WorkoutPlan) -> Void) async throws {
        guard let plan = findResult else { return }
        mutate(plan)
    }

    func publish(_ planID: UUID) async throws {}
    func remove(_ planID: UUID) async throws {}

    func addExercise(_ exerciseID: UUID, to planID: UUID) async throws -> PlanExercise {
        PlanExercise(order: 0, restDuration: 90, targetRepMin: 8, targetRepMax: 12)
    }

    func removeExercise(_ planExerciseID: UUID) async throws {}
    func reorder(planID: UUID, from: IndexSet, to: Int) async throws {}
    func setPlanSets(_ sets: [PlanSetDraft], for planExerciseID: UUID) async throws {}
    func setRest(_ duration: TimeInterval, for planExerciseID: UUID) async throws {}
}
