import Foundation

protocol WorkoutServicing: Sendable {
    func startSession(planID: UUID?) async throws -> WorkoutSessionDTO
    func resumeActiveSession() async throws -> WorkoutSessionDTO?
    func logSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int
    ) async throws -> WorkoutSetDTO
    func finishSession(_ sessionID: UUID) async throws -> WorkoutSessionDTO
    func cancelSession(_ sessionID: UUID) async throws
}
