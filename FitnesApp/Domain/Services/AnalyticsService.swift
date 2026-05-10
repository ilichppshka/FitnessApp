import Foundation

@MainActor
final class AnalyticsService: AnalyticsServicing {
    private let sessions: SessionRepository
    private let exercises: ExerciseRepository

    init(sessions: SessionRepository, exercises: ExerciseRepository) {
        self.sessions = sessions
        self.exercises = exercises
    }

    func weeklyTonnage(reference: Date) async throws -> [DailyTonnage] {
        let range = Calendar.iso8601WeekRange(reference: reference)
        let history = try await sessions.history(range: range)
        let buckets = Dictionary(
            grouping: history,
            by: { Calendar.startOfDay($0.startedAt) }
        )
        return range.allDays.map { day in
            let tonnage = buckets[day]?.reduce(0) { $0 + $1.totalTonnage } ?? 0
            return DailyTonnage(id: day, tonnage: tonnage)
        }
    }

    func monthlyTonnage(reference: Date) async throws -> [WeeklyTonnage] {
        let range = Calendar.iso8601MonthRange(reference: reference)
        let history = try await sessions.history(range: range)
        let buckets = Dictionary(
            grouping: history,
            by: { Calendar.iso8601WeekRange(reference: $0.startedAt).lowerBound }
        )
        return buckets
            .map { weekStart, items in
                WeeklyTonnage(
                    id: weekStart,
                    tonnage: items.reduce(0) { $0 + $1.totalTonnage },
                    sessionsCount: items.count
                )
            }
            .sorted { $0.id < $1.id }
    }

    func sessionHistory(limit: Int) async throws -> [WorkoutSessionDTO] {
        guard limit > 0 else { return [] }
        let history = try await sessions.history(range: Date.distantPast...Date.now)
        return Array(history.prefix(limit))
    }

    func personalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO? {
        try await exercises.bestPersonalRecord(exerciseID: exerciseID)
    }
}
