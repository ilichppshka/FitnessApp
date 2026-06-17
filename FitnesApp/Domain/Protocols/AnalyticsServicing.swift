import Foundation

protocol AnalyticsServicing: Sendable {
    // — Progress —
    func totalTonnage(range: DateRange) async throws -> Metric
    func tonnageSeries(range: DateRange) async throws -> [TonnagePoint]
    func sessionsCount(range: DateRange) async throws -> Metric
    func totalTime(range: DateRange) async throws -> Metric
    func newPRsCount(range: DateRange) async throws -> Metric
    func currentStreak() async throws -> Int

    // — Exercise Detail —
    func estimatedOneRepMax(exerciseID: UUID) async throws -> Double?
    func attempts(exerciseID: UUID) async throws -> Int

    // — Dashboard —
    func weekStates(weekOf date: Date) async throws -> [DayState]
    func weeklyVolume() async throws -> Metric
    func sessionRing() async throws -> (done: Int, planned: Int)
    func latestPR() async throws -> PersonalRecord?

    // — Plan —
    func estimatedDuration(planID: UUID) async throws -> TimeInterval
}
