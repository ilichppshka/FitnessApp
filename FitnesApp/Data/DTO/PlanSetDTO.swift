import Foundation

struct PlanSetDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let order: Int
    let targetWeight: Double?
    let targetReps: Int
}
