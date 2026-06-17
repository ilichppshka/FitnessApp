import Foundation

// MARK: - Range

enum DateRange: CaseIterable, Sendable {
    case week, month, threeMonths, year, all
}

// MARK: - Output types

struct Metric: Sendable, Equatable {
    let value: Double
    let deltaPercent: Double?
    let deltaAbsolute: Double?

    static func plain(_ value: Double) -> Self {
        Self(value: value, deltaPercent: nil, deltaAbsolute: nil)
    }
}

struct TonnagePoint: Sendable, Identifiable, Hashable {
    let date: Date
    let tonnage: Double
    var id: Date { date }
}

enum DayState: Sendable, Equatable {
    case done, today, planned, rest
}

// MARK: - Legacy aliases (used by existing AnalyticsService tests until migrated)

struct DailyTonnage: Sendable, Identifiable, Hashable {
    let id: Date
    let tonnage: Double
}

struct WeeklyTonnage: Sendable, Identifiable, Hashable {
    let id: Date
    let tonnage: Double
    let sessionsCount: Int
}
