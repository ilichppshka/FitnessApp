import Foundation

protocol ProgressionServicing: Sendable {
    func suggestion(
        exerciseID: UUID,
        plan: PlanExerciseDTO?
    ) async throws -> ProgressionSuggestion
}
