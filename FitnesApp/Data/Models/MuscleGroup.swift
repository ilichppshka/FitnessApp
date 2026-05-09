import Foundation
import SwiftData

@Model
final class MuscleGroup {
    @Attribute(.unique) var id: UUID
    var name: String

    @Relationship(inverse: \Exercise.muscleGroups)
    var exercises: [Exercise] = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
