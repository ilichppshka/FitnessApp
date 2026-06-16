import Foundation
import SwiftData

@Model
final class PlanExercise {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var exercise: Exercise?
    var order: Int
    var restDuration: TimeInterval
    var targetRepMin: Int
    var targetRepMax: Int

    @Relationship(deleteRule: .cascade, inverse: \PlanSet.planExercise)
    var planSets: [PlanSet] = []

    var targetSets: Int { planSets.count }

    init(
        id: UUID = UUID(),
        plan: WorkoutPlan? = nil,
        exercise: Exercise? = nil,
        order: Int,
        restDuration: TimeInterval = 120,
        targetRepMin: Int = 8,
        targetRepMax: Int = 12
    ) {
        self.id = id
        self.plan = plan
        self.exercise = exercise
        self.order = order
        self.restDuration = restDuration
        self.targetRepMin = targetRepMin
        self.targetRepMax = targetRepMax
    }
}
