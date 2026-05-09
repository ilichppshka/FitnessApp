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

        #expect(all.count == 30)
    }

    @Test
    func seederIsIdempotent() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let all = try await repo.all()

        #expect(all.count == 30)
    }

    @Test
    func searchByQueryFiltersByName() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        try DataSeeder.seedIfNeeded(context)
        let repo = SwiftDataExerciseRepository(context: context)

        let result = try await repo.search(query: "жим", muscleGroupIDs: [])

        #expect(!result.isEmpty)
        #expect(result.allSatisfy { $0.name.localizedCaseInsensitiveContains("жим") })
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
        #expect(result.allSatisfy { $0.muscleGroups.contains { $0.id == chest.id } })
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

    private func chestGroup(in context: ModelContext) async throws -> MuscleGroup? {
        let descriptor = FetchDescriptor<MuscleGroup>(
            predicate: #Predicate { $0.name == "Грудь" }
        )
        return try context.fetch(descriptor).first
    }
}
