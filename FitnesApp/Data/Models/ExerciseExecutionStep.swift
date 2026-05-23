import Foundation
import SwiftData

@Model
final class ExerciseExecutionStep {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var order: Int
    var key: String

    init(id: UUID = UUID(), exercise: Exercise, order: Int, key: String) {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.key = key
    }
}
