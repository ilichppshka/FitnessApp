import Foundation
import SwiftData

@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var session: WorkoutSession?
    var exercise: Exercise
    var setNumber: Int
    var weight: Double
    var reps: Int
    var tonnage: Double
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        session: WorkoutSession? = nil,
        exercise: Exercise,
        setNumber: Int,
        weight: Double,
        reps: Int,
        loggedAt: Date
    ) {
        self.id = id
        self.session = session
        self.exercise = exercise
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.tonnage = weight * Double(reps)
        self.loggedAt = loggedAt
    }
}
