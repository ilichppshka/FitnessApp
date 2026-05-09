import Foundation

struct PlanExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let order: Int
    let targetSets: Int
    let restDuration: TimeInterval
}
