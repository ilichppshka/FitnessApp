import Foundation
import SwiftData

@Model
final class PlanExercise {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var exercise: Exercise
    var order: Int
    var targetSets: Int
    var restDuration: TimeInterval

    init(
        id: UUID = UUID(),
        plan: WorkoutPlan? = nil,
        exercise: Exercise,
        order: Int,
        targetSets: Int,
        restDuration: TimeInterval
    ) {
        self.id = id
        self.plan = plan
        self.exercise = exercise
        self.order = order
        self.targetSets = targetSets
        self.restDuration = restDuration
    }
}
