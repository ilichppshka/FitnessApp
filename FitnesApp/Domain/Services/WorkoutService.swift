import Foundation

@MainActor
final class WorkoutService: WorkoutServicing {
    private let sessions: SessionRepository
    private let exercises: ExerciseRepository

    init(sessions: SessionRepository, exercises: ExerciseRepository) {
        self.sessions = sessions
        self.exercises = exercises
    }

    func startSession(planID: UUID?) async throws -> WorkoutSessionDTO {
        if let active = try await sessions.activeSession() {
            throw AppError.sessionAlreadyActive(id: active.id)
        }
        return try await sessions.create(planID: planID)
    }

    func resumeActiveSession() async throws -> WorkoutSessionDTO? {
        try await sessions.activeSession()
    }

    func logSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int
    ) async throws -> WorkoutSetDTO {
        guard weight >= 0, reps > 0 else { throw AppError.invalidSetInput }
        let tonnage = TonnageCalculator.compute(weight: weight, reps: reps)
        let setDTO = try await sessions.addSet(
            sessionID: sessionID,
            exerciseID: exerciseID,
            weight: weight,
            reps: reps,
            tonnage: tonnage
        )
        try await sessions.bumpTotalTonnage(sessionID: sessionID, by: tonnage)
        try await PersonalRecordCalculator.evaluateAndStoreIfNeeded(
            setDTO: setDTO,
            exercises: exercises
        )
        return setDTO
    }

    func finishSession(_ sessionID: UUID) async throws -> WorkoutSessionDTO {
        try await sessions.finish(sessionID: sessionID, at: .now)
    }

    func cancelSession(_ sessionID: UUID) async throws {
        try await sessions.delete(sessionID: sessionID)
    }
}
