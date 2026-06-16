import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var title: String
    var plan: WorkoutPlan?
    var startedAt: Date
    var finishedAt: Date?
    var totalTonnage: Double

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet] = []

    var isActive: Bool { finishedAt == nil }
    var duration: TimeInterval { (finishedAt ?? .now).timeIntervalSince(startedAt) }
    var containsPR: Bool { sets.contains(where: \.isPersonalRecord) }

    init(
        id: UUID = UUID(),
        title: String,
        plan: WorkoutPlan? = nil,
        startedAt: Date,
        finishedAt: Date? = nil,
        totalTonnage: Double = 0
    ) {
        self.id = id
        self.title = title
        self.plan = plan
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.totalTonnage = totalTonnage
    }
}
