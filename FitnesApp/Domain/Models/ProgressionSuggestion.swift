import Foundation

struct ProgressionSuggestion: Sendable {
    let suggestedWeight: Double
    let suggestedReps: Int
    let deltaVsLast: Double
    let lastSet: WorkoutSetDTO?
}
