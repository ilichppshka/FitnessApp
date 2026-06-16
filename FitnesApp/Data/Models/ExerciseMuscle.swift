import Foundation
import SwiftData

@Model
final class ExerciseMuscle {
    @Attribute(.unique) var id: UUID
    var role: MuscleRole
    var exercise: Exercise?
    var muscleGroup: MuscleGroup?

    init(
        id: UUID = UUID(),
        role: MuscleRole,
        exercise: Exercise? = nil,
        muscleGroup: MuscleGroup? = nil
    ) {
        self.id = id
        self.role = role
        self.exercise = exercise
        self.muscleGroup = muscleGroup
    }
}
