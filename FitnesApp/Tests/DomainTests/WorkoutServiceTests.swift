@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct WorkoutServiceTests {
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
        sessions.activeSessionResult = WorkoutSessionDTO(
            id: activeID,
            planName: nil,
            startedAt: .now,
            finishedAt: nil,
            totalTonnage: 0,
            sets: []
        )

        await #expect(throws: AppError.sessionAlreadyActive(id: activeID)) {
            _ = try await service.startSession(planID: nil)
        }
        #expect(sessions.createCalls.isEmpty)
    }

    @Test
    func resumeActiveSessionReturnsActive() async throws {
        let (service, sessions, _) = makeService()
        let id = UUID()
        sessions.activeSessionResult = WorkoutSessionDTO(
            id: id,
            planName: nil,
            startedAt: .now,
            finishedAt: nil,
            totalTonnage: 0,
            sets: []
        )

        let resumed = try await service.resumeActiveSession()

        #expect(resumed?.id == id)
    }

    @Test
    func logSetThrowsOnNegativeWeight() async throws {
        let (service, sessions, _) = makeService()

        await #expect(throws: AppError.invalidSetInput) {
            _ = try await service.logSet(
                sessionID: UUID(),
                exerciseID: UUID(),
                weight: -1,
                reps: 10
            )
        }
        #expect(sessions.addSetCalls.isEmpty)
    }

    @Test
    func logSetThrowsOnZeroReps() async throws {
        let (service, _, _) = makeService()

        await #expect(throws: AppError.invalidSetInput) {
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
        #expect(sessions.addSetCalls.count == 1)
    }

    @Test
    func logSetComputesTonnageAndBumpsTotal() async throws {
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
        let addCall = try #require(sessions.addSetCalls.first)
        #expect(addCall.tonnage == 600)
        let bumpCall = try #require(sessions.bumpCalls.first)
        #expect(bumpCall.sessionID == sessionID)
        #expect(bumpCall.delta == 600)
    }

    @Test
    func logSetRecordsPRWhenWeightExceedsBest() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now.addingTimeInterval(-86_400),
            weight: 80,
            reps: 5,
            tonnage: 400
        )

        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 90,
            reps: 5
        )

        #expect(exercises.addPRCalls.count == 1)
        #expect(exercises.addPRCalls.first?.weight == 90)
    }

    @Test
    func logSetSkipsPRWhenWeightNotBetter() async throws {
        let (service, _, exercises) = makeService()
        let exerciseID = UUID()
        exercises.bestPRResult = PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: .now.addingTimeInterval(-86_400),
            weight: 100,
            reps: 5,
            tonnage: 500
        )

        _ = try await service.logSet(
            sessionID: UUID(),
            exerciseID: exerciseID,
            weight: 90,
            reps: 5
        )

        #expect(exercises.addPRCalls.isEmpty)
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
    func cancelSessionDeletes() async throws {
        let (service, sessions, _) = makeService()
        let sessionID = UUID()

        try await service.cancelSession(sessionID)

        #expect(sessions.deleteCalls == [sessionID])
    }
}
