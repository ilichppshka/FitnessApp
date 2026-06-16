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
    var mistakeKeys: [String] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.exercise)
    var muscleLinks: [ExerciseMuscle] = []

    @Relationship(deleteRule: .cascade)
    var executionSteps: [ExerciseExecutionStep] = []

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord] = []

    var primaryMuscles: [MuscleGroup] {
        muscleLinks.filter { $0.role == .primary }.compactMap(\.muscleGroup)
    }

    var secondaryMuscles: [MuscleGroup] {
        muscleLinks.filter { $0.role == .secondary }.compactMap(\.muscleGroup)
    }

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
