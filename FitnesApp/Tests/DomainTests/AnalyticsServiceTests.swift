@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct AnalyticsServiceTests {
    // Wednesday 2026-05-13 12:00 UTC; ISO week Mon 2026-05-11 … Sun 2026-05-17
    private let reference = Date(timeIntervalSince1970: 1_778_932_800)

    // swiftlint:disable:next large_tuple
    private func makeService(now: Date? = nil) -> (AnalyticsService, MockSessionRepository, MockExerciseRepository, MockWorkoutRepository) {
        let sessions = MockSessionRepository()
        let exercises = MockExerciseRepository()
        let plans = MockWorkoutRepository()
        let fixedNow = now ?? Date(timeIntervalSince1970: 1_778_932_800)
        let service = AnalyticsService(
            sessions: sessions,
            exercises: exercises,
            plans: plans,
            now: { fixedNow }
        )
        return (service, sessions, exercises, plans)
    }

    private func session(
        startedAt: Date,
        tonnage: Double,
        sets: [WorkoutSetDTO] = [],
        finishedAt: Date? = nil
    ) -> WorkoutSessionDTO {
        WorkoutSessionDTO(
            id: UUID(),
            title: "Test",
            planName: nil,
            startedAt: startedAt,
            finishedAt: finishedAt ?? startedAt.addingTimeInterval(3600),
            totalTonnage: tonnage,
            sets: sets
        )
    }

    private func makeSet(exerciseID: UUID = UUID(), isPR: Bool = false) -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            setNumber: 1,
            weight: 100,
            reps: 5,
            tonnage: 500,
            isPersonalRecord: isPR,
            loggedAt: .now
        )
    }

    // MARK: - totalTonnage

    @Test
    func totalTonnageSumsCurrentRange() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let week = Calendar.iso8601WeekRange(reference: reference)
        sessions.historyResult = [
            session(startedAt: week.lowerBound.addingTimeInterval(3600), tonnage: 1000),
            session(startedAt: week.lowerBound.addingTimeInterval(7200), tonnage: 500)
        ]

        let metric = try await service.totalTonnage(range: .week)

        #expect(metric.value == 1500)
    }

    @Test
    func totalTonnageComputesDeltaVsPreviousWeek() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let thisWeek = Calendar.iso8601WeekRange(reference: reference)
        let prevRef = Calendar.iso8601.date(byAdding: .weekOfYear, value: -1, to: reference)!
        let prevWeek = Calendar.iso8601WeekRange(reference: prevRef)
        sessions.historyResult = [
            session(startedAt: thisWeek.lowerBound.addingTimeInterval(3600), tonnage: 1200),
            session(startedAt: prevWeek.lowerBound.addingTimeInterval(3600), tonnage: 1000)
        ]

        let metric = try await service.totalTonnage(range: .week)

        #expect(metric.value == 1200)
        #expect(metric.deltaAbsolute == 200)
    }

    // MARK: - tonnageSeries

    @Test
    func tonnageSeriesReturnsOnePointPerDay() async throws {
        let (service, _, _, _) = makeService(now: reference)

        let points = try await service.tonnageSeries(range: .week)

        #expect(points.count == 7)
        #expect(points.allSatisfy { $0.tonnage == 0 })
    }

    @Test
    func tonnageSeriesBucketsByDay() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let week = Calendar.iso8601WeekRange(reference: reference)
        let monday = week.lowerBound
        sessions.historyResult = [
            session(startedAt: monday.addingTimeInterval(3600), tonnage: 800),
            session(startedAt: monday.addingTimeInterval(7200), tonnage: 200),
            session(startedAt: monday.addingTimeInterval(2 * 86_400 + 3600), tonnage: 500)
        ]

        let points = try await service.tonnageSeries(range: .week)

        #expect(points[0].tonnage == 1000)
        #expect(points[2].tonnage == 500)
        #expect(points[1].tonnage == 0)
    }

    // MARK: - sessionsCount

    @Test
    func sessionsCountReturnsCountAndDelta() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let thisWeek = Calendar.iso8601WeekRange(reference: reference)
        let prevRef = Calendar.iso8601.date(byAdding: .weekOfYear, value: -1, to: reference)!
        let prevWeek = Calendar.iso8601WeekRange(reference: prevRef)
        sessions.historyResult = [
            session(startedAt: thisWeek.lowerBound.addingTimeInterval(3600), tonnage: 100),
            session(startedAt: thisWeek.lowerBound.addingTimeInterval(7200), tonnage: 100),
            session(startedAt: prevWeek.lowerBound.addingTimeInterval(3600), tonnage: 100)
        ]

        let metric = try await service.sessionsCount(range: .week)

        #expect(metric.value == 2)
        #expect(metric.deltaAbsolute == 1)
    }

    // MARK: - newPRsCount

    @Test
    func newPRsCountFiltersIsPersonalRecordFlag() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let week = Calendar.iso8601WeekRange(reference: reference)
        sessions.historyResult = [
            session(
                startedAt: week.lowerBound.addingTimeInterval(3600),
                tonnage: 0,
                sets: [makeSet(isPR: true), makeSet(isPR: false), makeSet(isPR: true)]
            )
        ]

        let metric = try await service.newPRsCount(range: .week)

        #expect(metric.value == 2)
    }

    // MARK: - currentStreak

    @Test
    func currentStreakIsZeroWithNoHistory() async throws {
        let (service, _, _, _) = makeService(now: reference)

        let streak = try await service.currentStreak()

        #expect(streak == 0)
    }

    @Test
    func currentStreakCountsConsecutiveDaysUpToToday() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let today = Calendar.iso8601.startOfDay(for: reference)
        let yesterday = today.addingTimeInterval(-86_400)
        let dayBefore = today.addingTimeInterval(-2 * 86_400)
        sessions.historyResult = [
            session(startedAt: today.addingTimeInterval(3600), tonnage: 0),
            session(startedAt: yesterday.addingTimeInterval(3600), tonnage: 0),
            session(startedAt: dayBefore.addingTimeInterval(3600), tonnage: 0)
        ]

        let streak = try await service.currentStreak()

        #expect(streak == 3)
    }

    @Test
    func currentStreakBreaksOnGap() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let today = Calendar.iso8601.startOfDay(for: reference)
        let twoDaysAgo = today.addingTimeInterval(-2 * 86_400)
        sessions.historyResult = [
            session(startedAt: today.addingTimeInterval(3600), tonnage: 0),
            session(startedAt: twoDaysAgo.addingTimeInterval(3600), tonnage: 0)
        ]

        let streak = try await service.currentStreak()

        #expect(streak == 1)
    }

    // MARK: - estimatedOneRepMax

    @Test
    func estimatedOneRepMaxReturnsNilWhenNoPR() async throws {
        let (service, _, exercises, _) = makeService()
        exercises.bestPRResult = nil

        let result = try await service.estimatedOneRepMax(exerciseID: UUID())

        #expect(result == nil)
    }

    @Test
    func estimatedOneRepMaxUsesEpleyFormula() async throws {
        let (service, _, exercises, _) = makeService()
        let exerciseID = UUID()
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now,
            weight: 100,
            reps: 10,
            tonnage: 1000
        )

        let result = try await service.estimatedOneRepMax(exerciseID: exerciseID)

        let expected = OneRepMaxCalculator.epley(weight: 100, reps: 10)
        #expect(result == expected)
    }

    // MARK: - attempts

    @Test
    func attemptsCountsSetsForExercise() async throws {
        let (service, sessions, _, _) = makeService(now: reference)
        let exerciseID = UUID()
        let otherID = UUID()
        sessions.historyResult = [
            session(
                startedAt: Date.distantPast.addingTimeInterval(1),
                tonnage: 0,
                sets: [makeSet(exerciseID: exerciseID), makeSet(exerciseID: otherID), makeSet(exerciseID: exerciseID)]
            )
        ]

        let count = try await service.attempts(exerciseID: exerciseID)

        #expect(count == 2)
    }

    // MARK: - estimatedDuration

    @Test
    func estimatedDurationIsZeroForUnknownPlan() async throws {
        let (service, _, _, plans) = makeService()
        plans.findResult = nil

        let duration = try await service.estimatedDuration(planID: UUID())

        #expect(duration == 0)
    }
}
