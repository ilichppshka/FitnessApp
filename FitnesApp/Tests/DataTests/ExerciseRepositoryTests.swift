@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct ExerciseRepositoryTests {
    @Test
    func seederPopulatesCatalog() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let all = try await repo.all()

        #expect(all.count == 14)
    }

    @Test
    func seederIsIdempotent() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let all = try await repo.all()

        #expect(all.count == 14)
    }

    @Test
    func searchByQueryEmptyReturnsAll() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let result = try await repo.search(query: "", muscleGroupIDs: [])

        #expect(result.count == 14)
    }

    @Test
    func searchByQueryNoMatchReturnsEmpty() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let result = try await repo.search(query: "xyz_impossible_xqz_123", muscleGroupIDs: [])

        #expect(result.isEmpty)
    }

    @Test
    func searchByMuscleGroupFiltersResults() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)
        let chest = try #require(try await chestGroup(in: context))

        let result = try await repo.search(query: "", muscleGroupIDs: [chest.id])

        #expect(!result.isEmpty)
        #expect(result.allSatisfy { exercise in
            exercise.primaryMuscles.contains { $0.id == chest.id } ||
            exercise.secondaryMuscles.contains { $0.id == chest.id }
        })
    }

    @Test
    func findByIdReturnsExercise() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)
        let any = try #require(try await repo.all().first)

        let found = try await repo.find(id: any.id)

        #expect(found?.id == any.id)
    }

    @Test
    func findByIdReturnsNilForUnknown() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let found = try await repo.find(id: UUID())

        #expect(found == nil)
    }

    @Test
    func muscleGroupsReturnsSeededGroupsSortedByDisplayOrder() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let groups = try await repo.muscleGroups()

        #expect(groups.count == MuscleGroupSeed.all.count)
        let orders = groups.map(\.displayOrder)
        #expect(orders == orders.sorted())
        #expect(Set(groups.map(\.slug)) == Set(MuscleGroupSeed.all))
    }

    @Test
    func setFavoriteTogglesAndPersists() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)
        let exercise = try #require(try await repo.all().first)
        let id = exercise.id

        try await repo.setFavorite(id, true)
        let after = try #require(try await repo.find(id: id))
        #expect(after.isFavorite == true)

        try await repo.setFavorite(id, false)
        let reverted = try #require(try await repo.find(id: id))
        #expect(reverted.isFavorite == false)
    }

    @Test
    func setFavoriteThrowsForUnknownID() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)
        let unknownID = UUID()

        await #expect(throws: DataError.exerciseNotFound(id: unknownID)) {
            try await repo.setFavorite(unknownID, true)
        }
    }

    private func chestGroup(in context: ModelContext) async throws -> MuscleGroup? {
        let descriptor = FetchDescriptor<MuscleGroup>(
            predicate: #Predicate { $0.slug == "chest" }
        )
        return try context.fetch(descriptor).first
    }
}
