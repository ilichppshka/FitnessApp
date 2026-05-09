import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionStart: String
    var descriptionExecution: String
    var descriptionErrors: String
    var animationAssetName: String?

    var muscleGroups: [MuscleGroup] = []

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord] = []

    init(
        id: UUID = UUID(),
        name: String,
        descriptionStart: String,
        descriptionExecution: String,
        descriptionErrors: String,
        animationAssetName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.descriptionStart = descriptionStart
        self.descriptionExecution = descriptionExecution
        self.descriptionErrors = descriptionErrors
        self.animationAssetName = animationAssetName
    }
}
