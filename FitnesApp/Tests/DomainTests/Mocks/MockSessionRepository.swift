@testable import FitnesApp
import Foundation

@MainActor
final class MockSessionRepository: SessionRepository {
    var activeSessionResult: WorkoutSession?
    var appendSetResult: WorkoutSet?
    var finishResult: WorkoutSessionDTO?
    var lastSetResult: WorkoutSetDTO?
    var historyResult: [WorkoutSessionDTO] = []

    private(set) var createCalls: [UUID?] = []
    struct AppendSetCall {
        let draft: WorkoutSetDraft
        let sessionID: UUID
    }

    private(set) var appendSetCalls: [AppendSetCall] = []
    private(set) var finishCalls: [(sessionID: UUID, date: Date)] = []
    private(set) var discardCalls: [UUID] = []
    private(set) var historyCalls: [ClosedRange<Date>] = []
    private(set) var lastSetCalls: [UUID] = []
    private(set) var clearHistoryCalled = false

    var appendSetError: Error?

    func activeSession() async throws -> WorkoutSession? {
        activeSessionResult
    }

    func create(planID: UUID?, title: String) async throws -> WorkoutSession {
        createCalls.append(planID)
        return WorkoutSession(title: title.isEmpty ? "Quick Workout" : title, startedAt: .now)
    }

    func appendSet(_ draft: WorkoutSetDraft, to sessionID: UUID) async throws -> WorkoutSet {
        appendSetCalls.append(AppendSetCall(draft: draft, sessionID: sessionID))
        if let appendSetError { throw appendSetError }
        if let appendSetResult { return appendSetResult }
        let mockExercise = Exercise(
            id: draft.exerciseID,
            slug: "mock-exercise",
            equipment: .barbell,
            difficulty: .beginner
        )
        let set = WorkoutSet(
            setNumber: appendSetCalls.count,
            weight: draft.weight,
            reps: draft.reps,
            loggedAt: .now
        )
        set.exercise = mockExercise
        set.tonnage = draft.tonnage
        return set
    }

    func finish(_ sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO {
        finishCalls.append((sessionID, date))
        if let finishResult { return finishResult }
        return WorkoutSessionDTO(
            id: sessionID,
            title: "Quick Workout",
            planName: nil,
            startedAt: date.addingTimeInterval(-3600),
            finishedAt: date,
            totalTonnage: 0,
            sets: []
        )
    }

    func discard(_ sessionID: UUID) async throws {
        discardCalls.append(sessionID)
    }

    func history(range: ClosedRange<Date>) async throws -> [WorkoutSessionDTO] {
        historyCalls.append(range)
        return historyResult.filter { range.contains($0.startedAt) }
    }

    func find(id: UUID) async throws -> WorkoutSessionDTO? {
        nil
    }

    func lastSet(exerciseID: UUID) async throws -> WorkoutSetDTO? {
        lastSetCalls.append(exerciseID)
        return lastSetResult
    }

    func clearHistory() async throws {
        clearHistoryCalled = true
    }
}
