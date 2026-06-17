@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct SessionRepositoryTests {
    @Test
    func createInsertsActiveSession() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataSessionRepository(context: container.mainContext)

        let session = try await repo.create(planID: nil, title: "Test")
        let active = try await repo.activeSession()

        #expect(session.finishedAt == nil)
        #expect(active?.id == session.id)
    }

    @Test
    func appendSetLinksToSession() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await sessionRepo.create(planID: nil, title: "")
        let draft = WorkoutSetDraft(
            exerciseID: exercise.id,
            weight: 60,
            reps: 10,
            tonnage: 600
        )

        let set = try await sessionRepo.appendSet(draft, to: session.id)

        #expect(set.tonnage == 600)
        #expect(set.setNumber == 1)
        let stored = try #require(try await sessionRepo.find(id: session.id))
        #expect(stored.sets.count == 1)
        #expect(stored.sets.first?.tonnage == 600)
    }

    @Test
    func appendSetIncrementsSetNumberPerExercise() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await sessionRepo.create(planID: nil, title: "")

        let first = try await sessionRepo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 50, reps: 8, tonnage: 400),
            to: session.id
        )
        let second = try await sessionRepo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 55, reps: 8, tonnage: 440),
            to: session.id
        )

        #expect(first.setNumber == 1)
        #expect(second.setNumber == 2)
    }

    @Test
    func appendSetAccumulatesTotalTonnage() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let repo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await repo.create(planID: nil, title: "")

        _ = try await repo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 60, reps: 10, tonnage: 600),
            to: session.id
        )
        _ = try await repo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 40, reps: 10, tonnage: 400),
            to: session.id
        )

        let stored = try #require(try await repo.find(id: session.id))
        #expect(stored.totalTonnage == 1000)
    }

    @Test
    func finishMarksFinishedAtAndClearsActive() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataSessionRepository(context: container.mainContext)
        let session = try await repo.create(planID: nil, title: "")
        let finishDate = Date()

        let finished = try await repo.finish(session.id, at: finishDate)

        #expect(finished.finishedAt == finishDate)
        let active = try await repo.activeSession()
        #expect(active == nil)
    }

    @Test
    func discardRemovesSession() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataSessionRepository(context: container.mainContext)
        let session = try await repo.create(planID: nil, title: "")

        try await repo.discard(session.id)

        #expect(try await repo.find(id: session.id) == nil)
    }

    @Test
    func historyReturnsOnlyFinishedInRange() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataSessionRepository(context: context)
        let now = Date()
        let inRange = try await repo.create(planID: nil, title: "")
        try mutateSessionStartedAt(context: context, id: inRange.id, to: now.addingTimeInterval(-3600))
        _ = try await repo.finish(inRange.id, at: now.addingTimeInterval(-1800))
        let outOfRange = try await repo.create(planID: nil, title: "")
        try mutateSessionStartedAt(
            context: context, id: outOfRange.id, to: now.addingTimeInterval(-86_400 * 30)
        )
        _ = try await repo.finish(outOfRange.id, at: now.addingTimeInterval(-86_400 * 30))
        _ = try await repo.create(planID: nil, title: "") // active, must be excluded

        let range = now.addingTimeInterval(-86_400)...now
        let history = try await repo.history(range: range)

        #expect(history.count == 1)
        #expect(history.first?.id == inRange.id)
    }

    @Test
    func findReturnsSession() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataSessionRepository(context: container.mainContext)
        let session = try await repo.create(planID: nil, title: "")

        let found = try await repo.find(id: session.id)

        #expect(found?.id == session.id)
    }

    @Test
    func lastSetReturnsLatestForExercise() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let session = try await sessionRepo.create(planID: nil, title: "")

        _ = try await sessionRepo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 60, reps: 8, tonnage: 480),
            to: session.id
        )
        _ = try await sessionRepo.appendSet(
            WorkoutSetDraft(exerciseID: exercise.id, weight: 70, reps: 8, tonnage: 560),
            to: session.id
        )

        let last = try await sessionRepo.lastSet(exerciseID: exercise.id)
        #expect(last?.weight == 70)
    }

    @Test
    func clearHistoryRemovesFinishedSessions() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataSessionRepository(context: container.mainContext)
        let s1 = try await repo.create(planID: nil, title: "")
        _ = try await repo.finish(s1.id, at: .now)
        let s2 = try await repo.create(planID: nil, title: "")
        _ = try await repo.finish(s2.id, at: .now)
        _ = try await repo.create(planID: nil, title: "") // active session - must survive

        try await repo.clearHistory()

        let history = try await repo.history(range: Date.distantPast...Date.distantFuture)
        let active = try await repo.activeSession()
        #expect(history.isEmpty)
        #expect(active != nil)
    }

    @Test
    func appendSetWithUnknownSessionThrows() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let exerciseRepo = SwiftDataExerciseRepository(context: context)
        let sessionRepo = SwiftDataSessionRepository(context: context)
        let exercise = try #require(try await exerciseRepo.all().first)
        let unknown = UUID()

        await #expect(throws: WorkoutError.sessionNotFound(id: unknown)) {
            _ = try await sessionRepo.appendSet(
                WorkoutSetDraft(exerciseID: exercise.id, weight: 50, reps: 8, tonnage: 400),
                to: unknown
            )
        }
    }

    private func mutateSessionStartedAt(
        context: ModelContext,
        id: UUID,
        to date: Date
    ) throws {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let session = try context.fetch(descriptor).first else { return }
        session.startedAt = date
        try context.save()
    }
}
