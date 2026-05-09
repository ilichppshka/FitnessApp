import Foundation

struct PersonalRecordDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let date: Date
    let weight: Double
    let reps: Int
    let tonnage: Double
}
