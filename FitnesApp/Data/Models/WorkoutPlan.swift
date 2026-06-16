import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String?
    var coverImageName: String?
    var accentColorHex: String?
    var scheduledWeekdays: [Int] = []
    var isDraft: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PlanExercise.plan)
    var planExercises: [PlanExercise] = []

    var totalSets: Int {
        planExercises.reduce(0) { $0 + $1.targetSets }
    }

    var targetMuscleGroups: [MuscleGroup] {
        Array(Set(planExercises.compactMap(\.exercise).flatMap(\.primaryMuscles)))
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: String? = nil,
        coverImageName: String? = nil,
        accentColorHex: String? = nil,
        scheduledWeekdays: [Int] = [],
        isDraft: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.coverImageName = coverImageName
        self.accentColorHex = accentColorHex
        self.scheduledWeekdays = scheduledWeekdays
        self.isDraft = isDraft
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
