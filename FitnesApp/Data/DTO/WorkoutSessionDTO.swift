import Foundation

struct WorkoutSessionDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let planName: String?
    let startedAt: Date
    let finishedAt: Date?
    let totalTonnage: Double
    let sets: [WorkoutSetDTO]
}
