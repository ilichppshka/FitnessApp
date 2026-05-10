@testable import FitnesApp
import Foundation

@MainActor
final class MockSessionRepository: SessionRepository {
    var activeSessionResult: WorkoutSessionDTO?
    var createResultByPlanID: [UUID?: WorkoutSessionDTO] = [:]
    var addSetResult: WorkoutSetDTO?
    var finishResult: WorkoutSessionDTO?

    private(set) var activeSessionCalls = 0
    private(set) var createCalls: [UUID?] = []
    private(set) var addSetCalls: [(sessionID: UUID, exerciseID: UUID, weight: Double, reps: Int, tonnage: Double)] = []
    private(set) var bumpCalls: [(sessionID: UUID, delta: Double)] = []
    private(set) var finishCalls: [(sessionID: UUID, date: Date)] = []
    private(set) var deleteCalls: [UUID] = []
    private(set) var historyCalls: [ClosedRange<Date>] = []
    private(set) var byIDCalls: [UUID] = []

    var addSetError: Error?
    var bumpError: Error?

    func activeSession() async throws -> WorkoutSessionDTO? {
        activeSessionCalls += 1
        return activeSessionResult
    }

    func create(planID: UUID?) async throws -> WorkoutSessionDTO {
        createCalls.append(planID)
        if let prepared = createResultByPlanID[planID] { return prepared }
        return WorkoutSessionDTO(
            id: UUID(),
            planName: nil,
            startedAt: .now,
            finishedAt: nil,
            totalTonnage: 0,
            sets: []
        )
    }

    func addSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        tonnage: Double
    ) async throws -> WorkoutSetDTO {
        addSetCalls.append((sessionID, exerciseID, weight, reps, tonnage))
        if let addSetError { throw addSetError }
        if let addSetResult { return addSetResult }
        return WorkoutSetDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            setNumber: addSetCalls.count,
            weight: weight,
            reps: reps,
            tonnage: tonnage,
            loggedAt: .now
        )
    }

    func bumpTotalTonnage(sessionID: UUID, by delta: Double) async throws {
        bumpCalls.append((sessionID, delta))
        if let bumpError { throw bumpError }
    }

    func finish(sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO {
        finishCalls.append((sessionID, date))
        if let finishResult { return finishResult }
        return WorkoutSessionDTO(
            id: sessionID,
            planName: nil,
            startedAt: date.addingTimeInterval(-3600),
            finishedAt: date,
            totalTonnage: 0,
            sets: []
        )
    }

    func delete(sessionID: UUID) async throws {
        deleteCalls.append(sessionID)
    }

    var historyResult: [WorkoutSessionDTO] = []
    var historyFilter: (@Sendable (WorkoutSessionDTO, ClosedRange<Date>) -> Bool)?

    func history(range: ClosedRange<Date>) async throws -> [WorkoutSessionDTO] {
        historyCalls.append(range)
        if let historyFilter {
            return historyResult.filter { historyFilter($0, range) }
        }
        return historyResult.filter { range.contains($0.startedAt) }
    }

    func byID(_ id: UUID) async throws -> WorkoutSessionDTO? {
        byIDCalls.append(id)
        return nil
    }
}
