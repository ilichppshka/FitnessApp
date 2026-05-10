import Foundation

protocol AnalyticsServicing: Sendable {
    func weeklyTonnage(reference: Date) async throws -> [DailyTonnage]
    func monthlyTonnage(reference: Date) async throws -> [WeeklyTonnage]
    func sessionHistory(limit: Int) async throws -> [WorkoutSessionDTO]
    func personalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO?
}
