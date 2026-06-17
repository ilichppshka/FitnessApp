@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct WorkoutRepositoryTests {
    @Test
    func createDraftInsertsDraftPlan() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        let draft = try await repo.createDraft()
        let all = try await repo.plans(includeDrafts: true)

        #expect(draft.isDraft)
        #expect(all.count == 1)
    }

    @Test
    func plansExcludesDrafts() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        _ = try await repo.createDraft()
        let published = try await repo.plans(includeDrafts: false)

        #expect(published.isEmpty)
    }

    @Test
    func publishSetsIsDraftFalse() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        let draft = try await repo.createDraft()
        try await repo.publish(draft.id)

        let stored = try #require(try await repo.find(id: draft.id))
        #expect(!stored.isDraft)
    }

    @Test
    func upsertMutatesPlan() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        let draft = try await repo.createDraft()
        try await repo.upsert(draft.id) { plan in
            plan.name = "Leg Day"
        }

        let stored = try #require(try await repo.find(id: draft.id))
        #expect(stored.name == "Leg Day")
    }

    @Test
    func removePlanDeletesIt() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        let draft = try await repo.createDraft()
        try await repo.remove(draft.id)

        let all = try await repo.plans(includeDrafts: true)
        #expect(all.isEmpty)
    }

    @Test
    func scheduledFiltersByWeekday() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataWorkoutRepository(context: container.mainContext)

        let draft = try await repo.createDraft()
        try await repo.upsert(draft.id) { plan in
            plan.scheduledWeekdays = [2, 4]
        }
        try await repo.publish(draft.id)

        let monday = try await repo.scheduled(weekday: 2)
        let wednesday = try await repo.scheduled(weekday: 4)
        let tuesday = try await repo.scheduled(weekday: 3)

        #expect(monday.count == 1)
        #expect(wednesday.count == 1)
        #expect(tuesday.isEmpty)
    }

    @Test
    func addExerciseAppendsWithIncrementingOrder() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercises = try await exerciseRepo.all()
        let draft = try await workoutRepo.createDraft()

        _ = try await workoutRepo.addExercise(exercises[0].id, to: draft.id)
        _ = try await workoutRepo.addExercise(exercises[1].id, to: draft.id)
        _ = try await workoutRepo.addExercise(exercises[2].id, to: draft.id)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        let ordered = stored.planExercises.sorted { $0.order < $1.order }
        #expect(ordered.map(\.order) == [0, 1, 2])
        #expect(ordered.compactMap { $0.exercise?.id } == exercises.prefix(3).map(\.id))
    }

    @Test
    func addExerciseCreatesDefaultPlanSet() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercise = try #require(try await exerciseRepo.all().first)
        let draft = try await workoutRepo.createDraft()

        _ = try await workoutRepo.addExercise(exercise.id, to: draft.id)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        let pe = try #require(stored.planExercises.first)
        #expect(pe.planSets.count == 1)
    }

    @Test
    func setPlanSetsReplacesExisting() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercise = try #require(try await exerciseRepo.all().first)
        let draft = try await workoutRepo.createDraft()
        let pe = try await workoutRepo.addExercise(exercise.id, to: draft.id)
        let newSets = [
            PlanSetDraft(order: 0, targetWeight: 80, targetReps: 5),
            PlanSetDraft(order: 1, targetWeight: 80, targetReps: 5),
            PlanSetDraft(order: 2, targetWeight: 80, targetReps: 5)
        ]

        try await workoutRepo.setPlanSets(newSets, for: pe.id)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        let storedPE = try #require(stored.planExercises.first)
        #expect(storedPE.planSets.count == 3)
        #expect(storedPE.planSets.allSatisfy { $0.targetWeight == 80 })
    }

    @Test
    func setRestUpdatesDuration() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercise = try #require(try await exerciseRepo.all().first)
        let draft = try await workoutRepo.createDraft()
        let pe = try await workoutRepo.addExercise(exercise.id, to: draft.id)

        try await workoutRepo.setRest(120, for: pe.id)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        #expect(stored.planExercises.first?.restDuration == 120)
    }

    @Test
    func reorderUpdatesOrderField() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercises = try await exerciseRepo.all()
        let draft = try await workoutRepo.createDraft()
        for ex in exercises.prefix(3) {
            _ = try await workoutRepo.addExercise(ex.id, to: draft.id)
        }

        try await workoutRepo.reorder(planID: draft.id, from: IndexSet(integer: 0), to: 3)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        let ordered = stored.planExercises.sorted { $0.order < $1.order }
        let expected = [exercises[1].id, exercises[2].id, exercises[0].id]
        #expect(ordered.compactMap { $0.exercise?.id } == expected)
        #expect(ordered.map(\.order) == [0, 1, 2])
    }

    @Test
    func removeExerciseDeletesPlanExercise() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercise = try #require(try await exerciseRepo.all().first)
        let draft = try await workoutRepo.createDraft()
        let pe = try await workoutRepo.addExercise(exercise.id, to: draft.id)

        try await workoutRepo.removeExercise(pe.id)

        let stored = try #require(try await workoutRepo.find(id: draft.id))
        #expect(stored.planExercises.isEmpty)
    }

    @Test
    func removePlanCascadesPlanExercises() async throws {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)
        let exercise = try #require(try await exerciseRepo.all().first)
        let draft = try await workoutRepo.createDraft()
        _ = try await workoutRepo.addExercise(exercise.id, to: draft.id)

        try await workoutRepo.remove(draft.id)

        let remainingPlans = try await workoutRepo.plans(includeDrafts: true)
        let remainingPE = try container.mainContext.fetch(FetchDescriptor<PlanExercise>())
        #expect(remainingPlans.isEmpty)
        #expect(remainingPE.isEmpty)
    }
}
