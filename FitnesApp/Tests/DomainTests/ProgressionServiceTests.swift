@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct ProgressionServiceTests {
    // swiftlint:disable:next large_tuple
    private func makeService() -> (ProgressionService, MockSessionRepository, MockExerciseRepository) {
        let sessions = MockSessionRepository()
        let exercises = MockExerciseRepository()
        let service = ProgressionService(sessions: sessions, exercises: exercises)
        return (service, sessions, exercises)
    }

    private func plan(repMin: Int = 8, repMax: Int = 12, targetWeight: Double? = nil) -> PlanExerciseDTO {
        PlanExerciseDTO(
            id: UUID(),
            exerciseID: nil,
            exerciseName: "mock",
            order: 0,
            targetSets: 3,
            targetRepMin: repMin,
            targetRepMax: repMax,
            restDuration: 90,
            planSets: targetWeight.map { weight in
                [PlanSetDTO(id: UUID(), order: 0, targetWeight: weight, targetReps: repMin)]
            } ?? []
        )
    }

    private func lastSet(weight: Double, reps: Int) -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: UUID(),
            exerciseID: UUID(),
            exerciseName: "mock",
            setNumber: 1,
            weight: weight,
            reps: reps,
            tonnage: weight * Double(reps),
            isPersonalRecord: false,
            loggedAt: .now
        )
    }

    @Test
    func noHistoryFallsBackToPlanTargets() async throws {
        let (service, sessions, _) = makeService()
        sessions.lastSetResult = nil
        let exerciseID = UUID()

        let result = try await service.suggestion(
            exerciseID: exerciseID,
            plan: plan(repMin: 8, repMax: 12, targetWeight: 60)
        )

        #expect(result.suggestedWeight == 60)
        #expect(result.suggestedReps == 8)
        #expect(result.deltaVsLast == 0)
        #expect(result.lastSet == nil)
    }

    @Test
    func noHistoryNoPlanUsesDefaults() async throws {
        let (service, sessions, _) = makeService()
        sessions.lastSetResult = nil

        let result = try await service.suggestion(exerciseID: UUID(), plan: nil)

        #expect(result.suggestedWeight == 0)
        #expect(result.suggestedReps == 8)
    }

    @Test
    func repsReachedTopIncrementsBarbellWeight() async throws {
        let (service, sessions, exercises) = makeService()
        sessions.lastSetResult = lastSet(weight: 80, reps: 12)
        exercises.lastSetExercise = Exercise(slug: "squat", equipment: .barbell, difficulty: .beginner)
        let exerciseID = UUID()

        let result = try await service.suggestion(
            exerciseID: exerciseID,
            plan: plan(repMin: 8, repMax: 12)
        )

        #expect(result.suggestedWeight == 82.5)
        #expect(result.suggestedReps == 6)
        #expect(result.deltaVsLast == 2.5)
    }

    @Test
    func repsNotAtTopSugggestsSameWeightPlusOneRep() async throws {
        let (service, sessions, exercises) = makeService()
        sessions.lastSetResult = lastSet(weight: 80, reps: 9)
        exercises.lastSetExercise = Exercise(slug: "squat", equipment: .barbell, difficulty: .beginner)

        let result = try await service.suggestion(
            exerciseID: UUID(),
            plan: plan(repMin: 8, repMax: 12)
        )

        #expect(result.suggestedWeight == 80)
        #expect(result.suggestedReps == 10)
        #expect(result.deltaVsLast == 0)
    }

    @Test
    func dumbbellEquipmentUsesSmallIncrement() async throws {
        let (service, sessions, exercises) = makeService()
        sessions.lastSetResult = lastSet(weight: 20, reps: 12)
        exercises.lastSetExercise = Exercise(slug: "curl", equipment: .dumbbell, difficulty: .beginner)

        let result = try await service.suggestion(
            exerciseID: UUID(),
            plan: plan(repMin: 8, repMax: 12)
        )

        #expect(result.suggestedWeight == 22)
    }

    @Test
    func bodyweightEquipmentUsesOneKgIncrement() async throws {
        let (service, sessions, exercises) = makeService()
        sessions.lastSetResult = lastSet(weight: 0, reps: 12)
        exercises.lastSetExercise = Exercise(slug: "pushup", equipment: .bodyweight, difficulty: .beginner)

        let result = try await service.suggestion(
            exerciseID: UUID(),
            plan: plan(repMin: 8, repMax: 12)
        )

        #expect(result.suggestedWeight == 1)
    }
}
