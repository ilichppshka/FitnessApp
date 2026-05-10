import Foundation

enum PersonalRecordCalculator {
    @discardableResult
    static func evaluateAndStoreIfNeeded(
        setDTO: WorkoutSetDTO,
        exercises: ExerciseRepository
    ) async throws -> PersonalRecordDTO? {
        let best = try await exercises.bestPersonalRecord(exerciseID: setDTO.exerciseID)
        guard setDTO.weight > (best?.weight ?? 0) else { return nil }
        return try await exercises.addPersonalRecord(
            exerciseID: setDTO.exerciseID,
            weight: setDTO.weight,
            reps: setDTO.reps,
            date: setDTO.loggedAt
        )
    }
}
