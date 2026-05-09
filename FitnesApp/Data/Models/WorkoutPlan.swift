import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetMuscleGroups: [MuscleGroup] = []

    @Relationship(deleteRule: .cascade, inverse: \PlanExercise.plan)
    var planExercises: [PlanExercise] = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
