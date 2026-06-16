import Foundation
import SwiftData

@Model
final class MuscleGroup {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var slug: String
    var displayOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.muscleGroup)
    var exerciseLinks: [ExerciseMuscle] = []

    init(id: UUID = UUID(), slug: String, displayOrder: Int = 0) {
        self.id = id
        self.slug = slug
        self.displayOrder = displayOrder
    }
}
