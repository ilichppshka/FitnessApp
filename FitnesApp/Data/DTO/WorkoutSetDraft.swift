import Foundation

struct WorkoutSetDraft: Sendable {
    let exerciseID: UUID
    let weight: Double
    let reps: Int
    let tonnage: Double
}
