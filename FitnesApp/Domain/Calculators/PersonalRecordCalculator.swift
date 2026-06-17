import Foundation

enum PersonalRecordCalculator {
    @discardableResult
    static func evaluateAndStoreIfNeeded(
        setDTO: WorkoutSetDTO,
        exercises: ExerciseRepository
    ) async throws -> PersonalRecordDTO? {
        guard let exerciseID = setDTO.exerciseID else { return nil }
        let best = try await exercises.bestPersonalRecord(exerciseID: exerciseID)
        let newOneRM = OneRepMaxCalculator.epley(weight: setDTO.weight, reps: setDTO.reps)
        let bestOneRM = best.map { OneRepMaxCalculator.epley(weight: $0.weight, reps: $0.reps) } ?? 0
        guard newOneRM > bestOneRM else { return nil }
        return try await exercises.addPersonalRecord(
            exerciseID: exerciseID,
            weight: setDTO.weight,
            reps: setDTO.reps,
            date: setDTO.loggedAt
        )
    }
}
