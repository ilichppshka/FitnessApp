@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct WorkoutRepositoryTests {
    @Test
    func upsertInsertsNewPlan() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataWorkoutRepository(context: context)
        let plan = WorkoutPlan(name: "Push Day")

        try await repo.upsert(plan)

        let all = try await repo.all()
        #expect(all.count == 1)
        #expect(all.first?.name == "Push Day")
    }

    @Test
    func addExerciseAppendsWithIncrementingOrder() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let workoutRepo = SwiftDataWorkoutRepository(context: context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let exercises = try await exerciseRepo.all()
        let plan = WorkoutPlan(name: "Plan")
        try await workoutRepo.upsert(plan)

        try await workoutRepo.addExercise(exercises[0], to: plan, targetSets: 3, restDuration: 90)
        try await workoutRepo.addExercise(exercises[1], to: plan, targetSets: 4, restDuration: 120)
        try await workoutRepo.addExercise(exercises[2], to: plan, targetSets: 3, restDuration: 60)

        let stored = try #require(try await workoutRepo.find(id: plan.id))
        let ordered = stored.planExercises.sorted { $0.order < $1.order }
        #expect(ordered.map(\.order) == [0, 1, 2])
        #expect(ordered.map { $0.exercise.id } == exercises.prefix(3).map(\.id))
    }

    @Test
    func reorderUpdatesOrderField() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let workoutRepo = SwiftDataWorkoutRepository(context: context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let exercises = try await exerciseRepo.all()
        let plan = WorkoutPlan(name: "Plan")
        try await workoutRepo.upsert(plan)
        for ex in exercises.prefix(3) {
            try await workoutRepo.addExercise(ex, to: plan, targetSets: 3, restDuration: 60)
        }

        try await workoutRepo.reorder(plan: plan, from: IndexSet(integer: 0), to: 3)

        let stored = try #require(try await workoutRepo.find(id: plan.id))
        let ordered = stored.planExercises.sorted { $0.order < $1.order }
        let expected = [exercises[1].id, exercises[2].id, exercises[0].id]
        #expect(ordered.map { $0.exercise.id } == expected)
        #expect(ordered.map(\.order) == [0, 1, 2])
    }

    @Test
    func deleteCascadesPlanExercises() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let workoutRepo = SwiftDataWorkoutRepository(context: context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let plan = WorkoutPlan(name: "Plan")
        try await workoutRepo.upsert(plan)
        try await workoutRepo.addExercise(exercise, to: plan, targetSets: 3, restDuration: 60)

        try await workoutRepo.delete(plan)

        let remainingPlans = try await workoutRepo.all()
        let remainingPE = try context.fetch(FetchDescriptor<PlanExercise>())
        #expect(remainingPlans.isEmpty)
        #expect(remainingPE.isEmpty)
    }

    @Test
    func removePlanExerciseDeletesIt() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let workoutRepo = SwiftDataWorkoutRepository(context: context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let plan = WorkoutPlan(name: "Plan")
        try await workoutRepo.upsert(plan)
        try await workoutRepo.addExercise(exercise, to: plan, targetSets: 3, restDuration: 60)
        let pe = try #require(plan.planExercises.first)

        try await workoutRepo.remove(pe)

        let stored = try #require(try await workoutRepo.find(id: plan.id))
        #expect(stored.planExercises.isEmpty)
    }
}
