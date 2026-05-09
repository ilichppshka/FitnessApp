import Foundation

struct ExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let descriptionStart: String
    let descriptionExecution: String
    let descriptionErrors: String
    let animationAssetName: String?
    let muscleGroups: [String]
}
