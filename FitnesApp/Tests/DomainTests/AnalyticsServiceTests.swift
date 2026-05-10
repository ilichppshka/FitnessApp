@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct AnalyticsServiceTests {
    private func makeService() -> (
        AnalyticsService,
        MockSessionRepository,
        MockExerciseRepository
    ) {
        let sessions = MockSessionRepository()
        let exercises = MockExerciseRepository()
        let service = AnalyticsService(sessions: sessions, exercises: exercises)
        return (service, sessions, exercises)
    }

    // Wednesday 2026-05-13 12:00 UTC; ISO week = Mon 2026-05-11 ... Sun 2026-05-17.
    private let reference = Date(timeIntervalSince1970: 1_778_932_800)

    private func session(
        startedAt: Date,
        tonnage: Double,
        finished: Bool = true
    ) -> WorkoutSessionDTO {
        WorkoutSessionDTO(
            id: UUID(),
            planName: nil,
            startedAt: startedAt,
            finishedAt: finished ? startedAt.addingTimeInterval(3600) : nil,
            totalTonnage: tonnage,
            sets: []
        )
    }

    @Test
    func weeklyTonnageReturnsSevenDays() async throws {
        let (service, _, _) = makeService()

        let result = try await service.weeklyTonnage(reference: reference)

        #expect(result.count == 7)
        #expect(result.allSatisfy { $0.tonnage == 0 })
    }

    @Test
    func weeklyTonnageBucketsByDay() async throws {
        let (service, sessions, _) = makeService()
        let week = Calendar.iso8601WeekRange(reference: reference)
        let monday = week.lowerBound
        let wednesday = monday.addingTimeInterval(2 * 86_400)
        sessions.historyResult = [
            session(startedAt: monday.addingTimeInterval(3600), tonnage: 500),
            session(startedAt: monday.addingTimeInterval(7200), tonnage: 250),
            session(startedAt: wednesday, tonnage: 1000)
        ]

        let result = try await service.weeklyTonnage(reference: reference)

        #expect(result.count == 7)
        #expect(result[0].tonnage == 750)
        #expect(result[2].tonnage == 1000)
        #expect(result[1].tonnage == 0)
    }

    @Test
    func weeklyTonnageQueriesRepoWithIsoWeekRange() async throws {
        let (service, sessions, _) = makeService()

        _ = try await service.weeklyTonnage(reference: reference)

        let call = try #require(sessions.historyCalls.first)
        let expected = Calendar.iso8601WeekRange(reference: reference)
        #expect(call.lowerBound == expected.lowerBound)
        #expect(call.upperBound == expected.upperBound)
    }

    @Test
    func monthlyTonnageGroupsByWeek() async throws {
        let (service, sessions, _) = makeService()
        let monthRange = Calendar.iso8601MonthRange(reference: reference)
        let weekA = Calendar.iso8601WeekRange(reference: monthRange.lowerBound).lowerBound
        let weekAStart = max(weekA, monthRange.lowerBound).addingTimeInterval(3600)
        let weekB = Calendar.iso8601WeekRange(reference: reference).lowerBound.addingTimeInterval(3600)
        sessions.historyResult = [
            session(startedAt: weekAStart, tonnage: 200),
            session(startedAt: weekAStart.addingTimeInterval(86_400), tonnage: 300),
            session(startedAt: weekB, tonnage: 1000)
        ]

        let result = try await service.monthlyTonnage(reference: reference)

        #expect(result.count == 2)
        #expect(result[0].tonnage == 500)
        #expect(result[0].sessionsCount == 2)
        #expect(result[1].tonnage == 1000)
        #expect(result[1].sessionsCount == 1)
        #expect(result[0].id < result[1].id)
    }

    @Test
    func sessionHistoryRespectsLimit() async throws {
        let (service, sessions, _) = makeService()
        let anchor = Date.now.addingTimeInterval(-86_400)
        sessions.historyResult = (0..<5).map { offset in
            session(
                startedAt: anchor.addingTimeInterval(-Double(offset) * 86_400),
                tonnage: Double(offset * 100)
            )
        }

        let result = try await service.sessionHistory(limit: 3)

        #expect(result.count == 3)
    }

    @Test
    func sessionHistoryWithZeroLimitReturnsEmpty() async throws {
        let (service, sessions, _) = makeService()
        sessions.historyResult = [session(startedAt: reference, tonnage: 100)]

        let result = try await service.sessionHistory(limit: 0)

        #expect(result.isEmpty)
        #expect(sessions.historyCalls.isEmpty)
    }

    @Test
    func personalRecordDelegatesToExercises() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        let expected = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: reference,
            weight: 120,
            reps: 3,
            tonnage: 360
        )
        exercises.bestPRResult = expected

        let result = try await service.personalRecord(exerciseID: exerciseID)

        #expect(result == expected)
        #expect(exercises.bestPRCalls == [exerciseID])
    }
}
