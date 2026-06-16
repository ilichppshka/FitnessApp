import Foundation

enum PersonalRecordCalculator {
    @discardableResult
    static func evaluateAndStoreIfNeeded(
        setDTO: WorkoutSetDTO,
        exercises: ExerciseRepository
    ) async throws -> PersonalRecordDTO? {
        guard let exerciseID = setDTO.exerciseID else { return nil }
        let best = try await exercises.bestPersonalRecord(exerciseID: exerciseID)
        guard setDTO.weight > (best?.weight ?? 0) else { return nil }
        return try await exercises.addPersonalRecord(
            exerciseID: exerciseID,
            weight: setDTO.weight,
            reps: setDTO.reps,
            date: setDTO.loggedAt
        )
    }
}
