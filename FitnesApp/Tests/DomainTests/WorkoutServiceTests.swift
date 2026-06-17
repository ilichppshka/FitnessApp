@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct WorkoutServiceTests {
    // swiftlint:disable:next large_tuple
    private func makeService() -> (
        WorkoutService,
        MockSessionRepository,
        MockExerciseRepository
    ) {
        let sessions = MockSessionRepository()
        let exercises = MockExerciseRepository()
        let service = WorkoutService(sessions: sessions, exercises: exercises)
        return (service, sessions, exercises)
    }

    @Test
    func startSessionCreatesNewWhenNoneActive() async throws {
        let (service, sessions, _) = makeService()

        let session = try await service.startSession(planID: nil)

        #expect(sessions.createCalls == [nil])
        #expect(session.finishedAt == nil)
    }

    @Test
    func startSessionThrowsWhenAlreadyActive() async throws {
        let (service, sessions, _) = makeService()
        let activeID = UUID()
        sessions.activeSessionResult = WorkoutSession(
            id: activeID,
            title: "Active",
            startedAt: .now
        )

        await #expect(throws: WorkoutError.sessionAlreadyActive(id: activeID)) {
            _ = try await service.startSession(planID: nil)
        }
        #expect(sessions.createCalls.isEmpty)
    }

    @Test
    func resumeActiveSessionReturnsActive() async throws {
        let (service, sessions, _) = makeService()
        let id = UUID()
        sessions.activeSessionResult = WorkoutSession(
            id: id,
            title: "Active",
            startedAt: .now
        )

        let resumed = try await service.resumeActiveSession()

        #expect(resumed?.id == id)
    }

    @Test
    func logSetThrowsOnNegativeWeight() async throws {
        let (service, sessions, _) = makeService()

        await #expect(throws: WorkoutError.invalidSetInput) {
            _ = try await service.logSet(
                sessionID: UUID(),
                exerciseID: UUID(),
                weight: -1,
                reps: 10
            )
        }
        #expect(sessions.appendSetCalls.isEmpty)
    }

    @Test
    func logSetThrowsOnZeroReps() async throws {
        let (service, _, _) = makeService()

        await #expect(throws: WorkoutError.invalidSetInput) {
            _ = try await service.logSet(
                sessionID: UUID(),
                exerciseID: UUID(),
                weight: 50,
                reps: 0
            )
        }
    }

    @Test
    func logSetAllowsBodyweightZero() async throws {
        let (service, sessions, _) = makeService()
        let sessionID = UUID()
        let exerciseID = UUID()

        let set = try await service.logSet(
            sessionID: sessionID,
            exerciseID: exerciseID,
            weight: 0,
            reps: 12
        )

        #expect(set.weight == 0)
        #expect(set.reps == 12)
        #expect(set.tonnage == 0)
        #expect(sessions.appendSetCalls.count == 1)
    }

    @Test
    func logSetComputesTonnageInDraft() async throws {
        let (service, sessions, _) = makeService()
        let sessionID = UUID()
        let exerciseID = UUID()

        let set = try await service.logSet(
            sessionID: sessionID,
            exerciseID: exerciseID,
            weight: 60,
            reps: 10
        )

        #expect(set.tonnage == 600)
        let call = try #require(sessions.appendSetCalls.first)
        #expect(call.draft.tonnage == 600)
        #expect(call.sessionID == sessionID)
    }

    // PR detection tests now use Epley 1RM logic
    @Test
    func logSetRecordsPRWhenEpleyExceedsBest() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        // Best: 80kg × 5 → Epley = 80 * (1 + 5/30) ≈ 93.3
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now.addingTimeInterval(-86_400),
            weight: 80,
            reps: 5,
            tonnage: 400
        )

        // New: 75kg × 12 → Epley = 75 * (1 + 12/30) = 105 → beats 93.3
        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 75,
            reps: 12
        )

        #expect(exercises.addPRCalls.count == 1)
    }

    @Test
    func logSetSkipsPRWhenEpleyNotBetter() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        // Best: 100kg × 5 → Epley = 100 * (1 + 5/30) ≈ 116.7
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now.addingTimeInterval(-86_400),
            weight: 100,
            reps: 5,
            tonnage: 500
        )

        // New: 90kg × 5 → Epley = 90 * (1 + 5/30) = 105 → doesn't beat 116.7
        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 90,
            reps: 5
        )

        #expect(exercises.addPRCalls.isEmpty)
    }

    @Test
    func logSetEpleyAllowsHigherRepsToBeakHigherWeight() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        // Best: 105kg × 1 → Epley = 105 * (1 + 1/30) ≈ 108.5
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now.addingTimeInterval(-86_400),
            weight: 105,
            reps: 1,
            tonnage: 105
        )

        // New: 100kg × 8 → Epley = 100 * (1 + 8/30) ≈ 126.7 → beats 108.5
        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 100,
            reps: 8
        )

        #expect(exercises.addPRCalls.count == 1)
    }

    @Test
    func logSetRecordsFirstPRWhenNonePresent() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        exercises.bestPRResult = nil

        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 50,
            reps: 8
        )

        #expect(exercises.addPRCalls.count == 1)
    }

    @Test
    func finishSessionDelegatesToRepo() async throws {
        let (service, sessions, _) = makeService()
        let sessionID = UUID()

        _ = try await service.finishSession(sessionID)

        let call = try #require(sessions.finishCalls.first)
        #expect(call.sessionID == sessionID)
    }

    @Test
    func discardSessionDeletes() async throws {
        let (service, sessions, _) = makeService()
        let sessionID = UUID()

        try await service.discardSession(sessionID)

        #expect(sessions.discardCalls == [sessionID])
    }
}
