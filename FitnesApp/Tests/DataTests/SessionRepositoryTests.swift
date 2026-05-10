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

        #expect(session.finishedAt == nil)
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

        let set = try await sessionRepo.addSet(
            sessionID: session.id,
            exerciseID: exercise.id,
            weight: 60,
            reps: 10,
            tonnage: 600
        )

        #expect(set.tonnage == 600)
        #expect(set.setNumber == 1)
        let stored = try #require(try await sessionRepo.byID(session.id))
        #expect(stored.sets.count == 1)
        #expect(stored.sets.first?.tonnage == 600)
    }

    @Test
    func addSetIncrementsSetNumberPerExercise() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await sessionRepo.create(planID: nil)

        let first = try await sessionRepo.addSet(
            sessionID: session.id,
            exerciseID: exercise.id,
            weight: 50,
            reps: 8,
            tonnage: 400
        )
        let second = try await sessionRepo.addSet(
            sessionID: session.id,
            exerciseID: exercise.id,
            weight: 55,
            reps: 8,
            tonnage: 440
        )

        #expect(first.setNumber == 1)
        #expect(second.setNumber == 2)
    }

    @Test
    func bumpTotalTonnageAccumulates() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let session = try await repo.create(planID: nil)

        try await repo.bumpTotalTonnage(sessionID: session.id, by: 600)
        try await repo.bumpTotalTonnage(sessionID: session.id, by: 400)

        let stored = try #require(try await repo.byID(session.id))
        #expect(stored.totalTonnage == 1000)
    }

    @Test
    func finishMarksFinishedAtAndClearsActive() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let session = try await repo.create(planID: nil)
        let finishDate = Date()

        let finished = try await repo.finish(sessionID: session.id, at: finishDate)

        #expect(finished.finishedAt == finishDate)
        let active = try await repo.activeSession()
        #expect(active == nil)
    }

    @Test
    func deleteRemovesSession() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let session = try await repo.create(planID: nil)

        try await repo.delete(sessionID: session.id)

        #expect(try await repo.byID(session.id) == nil)
    }

    @Test
    func historyReturnsOnlyFinishedInRange() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let now = Date()
        let inRange = try await repo.create(planID: nil)
        try await mutateSessionStartedAt(context: context, id: inRange.id, to: now.addingTimeInterval(-3600))
        _ = try await repo.finish(sessionID: inRange.id, at: now.addingTimeInterval(-1800))
        let outOfRange = try await repo.create(planID: nil)
        try await mutateSessionStartedAt(context: context, id: outOfRange.id, to: now.addingTimeInterval(-86_400 * 30))
        _ = try await repo.finish(sessionID: outOfRange.id, at: now.addingTimeInterval(-86_400 * 30))
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

    @Test
    func addSetWithUnknownSessionThrows() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let unknown = UUID()

        await #expect(throws: AppError.sessionNotFound(id: unknown)) {
            _ = try await sessionRepo.addSet(
                sessionID: unknown,
                exerciseID: exercise.id,
                weight: 50,
                reps: 8,
                tonnage: 400
            )
        }
    }

    private func mutateSessionStartedAt(
        context: ModelContext,
        id: UUID,
        to date: Date
    ) async throws {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let session = try context.fetch(descriptor).first else { return }
        session.startedAt = date
        try context.save()
    }
}
