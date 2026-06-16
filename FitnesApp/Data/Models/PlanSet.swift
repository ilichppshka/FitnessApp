import Foundation
import SwiftData

@Model
final class PlanSet {
    @Attribute(.unique) var id: UUID
    var planExercise: PlanExercise?
    var order: Int
    var targetWeight: Double?
    var targetReps: Int

    init(
        id: UUID = UUID(),
        planExercise: PlanExercise? = nil,
        order: Int,
        targetWeight: Double? = nil,
        targetReps: Int
    ) {
        self.id = id
        self.planExercise = planExercise
        self.order = order
        self.targetWeight = targetWeight
        self.targetReps = targetReps
    }
}
