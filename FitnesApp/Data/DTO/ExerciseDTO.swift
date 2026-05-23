import Foundation

struct ExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let slug: String
    let equipment: ExerciseEquipment
    let difficulty: ExerciseDifficulty
    let primaryMuscleGroupSlugs: [String]
    let secondaryMuscleGroupSlugs: [String]
    let animationAssetName: String?
}
