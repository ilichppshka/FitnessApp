import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var startedAt: Date
    var finishedAt: Date?
    var totalTonnage: Double

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet] = []

    var isActive: Bool { finishedAt == nil }

    init(
        id: UUID = UUID(),
        plan: WorkoutPlan? = nil,
        startedAt: Date,
        finishedAt: Date? = nil,
        totalTonnage: Double = 0
    ) {
        self.id = id
        self.plan = plan
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.totalTonnage = totalTonnage
    }
}
