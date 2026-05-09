@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct SessionRepositoryTests {
    @Test
    func createInsertsActiveSession() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)

        let session = try await repo.create(planID: nil)
        let active = try await repo.activeSession()

        #expect(session.isActive)
        #expect(active?.id == session.id)
    }

    @Test
    func addSetLinksToSession() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await sessionRepo.create(planID: nil)
        let set = WorkoutSet(
            exercise: exercise,
            setNumber: 1,
            weight: 60,
            reps: 10,
            loggedAt: Date()
        )

        try await sessionRepo.addSet(set, to: session)

        let stored = try #require(try await sessionRepo.byID(session.id))
        #expect(stored.sets.count == 1)
        #expect(stored.sets.first?.tonnage == 600)
    }

    @Test
    func finishMarksFinishedAtAndClearsActive() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let session = try await repo.create(planID: nil)
        let finishDate = Date()

        try await repo.finish(session, at: finishDate)

        #expect(session.finishedAt == finishDate)
        let active = try await repo.activeSession()
        #expect(active == nil)
    }

    @Test
    func historyReturnsOnlyFinishedInRange() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let now = Date()
        let inRange = try await repo.create(planID: nil)
        inRange.startedAt = now.addingTimeInterval(-3600)
        try await repo.finish(inRange, at: now.addingTimeInterval(-1800))
        let outOfRange = try await repo.create(planID: nil)
        outOfRange.startedAt = now.addingTimeInterval(-86_400 * 30)
        try await repo.finish(outOfRange, at: now.addingTimeInterval(-86_400 * 30))
        _ = try await repo.create(planID: nil) // active, must be excluded

        let range = now.addingTimeInterval(-86_400)...now
        let history = try await repo.history(range: range)

        #expect(history.count == 1)
        #expect(history.first?.id == inRange.id)
    }

    @Test
    func byIDReturnsSession() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let session = try await repo.create(planID: nil)

        let found = try await repo.byID(session.id)

        #expect(found?.id == session.id)
    }
}
