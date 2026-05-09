import Foundation

struct WorkoutSetDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let setNumber: Int
    let weight: Double
    let reps: Int
    let tonnage: Double
    let loggedAt: Date
}
