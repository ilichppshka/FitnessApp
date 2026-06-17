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
            throw WorkoutError.sessionAlreadyActive(id: active.id)
        }
        let session = try await sessions.create(planID: planID, title: "")
        return session.toDTO()
    }

    func resumeActiveSession() async throws -> WorkoutSessionDTO? {
        try await sessions.activeSession()?.toDTO()
    }

    @discardableResult
    func logSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int
    ) async throws -> WorkoutSetDTO {
        guard weight >= 0, reps > 0 else { throw WorkoutError.invalidSetInput }
        let tonnage = TonnageCalculator.compute(weight: weight, reps: reps)
        let draft = WorkoutSetDraft(exerciseID: exerciseID, weight: weight, reps: reps, tonnage: tonnage)
        let set = try await sessions.appendSet(draft, to: sessionID)
        let setDTO = set.toDTO()
        try await PersonalRecordCalculator.evaluateAndStoreIfNeeded(
            setDTO: setDTO,
            exercises: exercises
        )
        return setDTO
    }

    func finishSession(_ sessionID: UUID) async throws -> WorkoutSessionDTO {
        try await sessions.finish(sessionID, at: .now)
    }

    func discardSession(_ sessionID: UUID) async throws {
        try await sessions.discard(sessionID)
    }
}
