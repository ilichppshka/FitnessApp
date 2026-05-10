import Foundation

struct DailyTonnage: Sendable, Identifiable, Hashable {
    let id: Date
    let tonnage: Double
}

struct WeeklyTonnage: Sendable, Identifiable, Hashable {
    let id: Date
    let tonnage: Double
    let sessionsCount: Int
}
