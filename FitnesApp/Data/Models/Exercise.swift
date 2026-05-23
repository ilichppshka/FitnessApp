import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var slug: String
    var equipment: ExerciseEquipment
    var difficulty: ExerciseDifficulty
    var animationAssetName: String?
    var isFavorite: Bool = false

    var primaryMuscleGroups: [MuscleGroup] = []
    var secondaryMuscleGroups: [MuscleGroup] = []
    var mistakeKeys: [String] = []

    @Relationship(deleteRule: .cascade)
    var executionSteps: [ExerciseExecutionStep] = []

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord] = []

    init(
        id: UUID = UUID(),
        slug: String,
        equipment: ExerciseEquipment,
        difficulty: ExerciseDifficulty,
        animationAssetName: String? = nil
    ) {
        self.id = id
        self.slug = slug
        self.equipment = equipment
        self.difficulty = difficulty
        self.animationAssetName = animationAssetName
    }
}
