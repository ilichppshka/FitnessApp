@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct ExerciseDetailViewModelTests {
    @Test
    func loadSetsExercise() async throws {
        let (vm, repo, _container) = try makeVM()
        let exercise = try #require(try await repo.all().first)

        await vm.load(id: exercise.id)

        #expect(vm.exercise?.id == exercise.id)
        #expect(vm.errorMessage == nil)
        #expect(!vm.isLoading)
        _ = _container
    }

    @Test
    func loadUnknownIdSetsError() async throws {
        let (vm, _, _container) = try makeVM()

        await vm.load(id: UUID())

        #expect(vm.exercise == nil)
        #expect(vm.errorMessage != nil)
        #expect(!vm.isLoading)
        _ = _container
    }

    @Test
    func toggleFavoritePersistsChange() async throws {
        let (vm, repo, _container) = try makeVM()
        let exercise = try #require(try await repo.all().first)
        await vm.load(id: exercise.id)
        let before = exercise.isFavorite

        await vm.toggleFavorite()

        let reloaded = try #require(try await repo.find(id: exercise.id))
        #expect(reloaded.isFavorite == !before)
        #expect(vm.errorMessage == nil)
        _ = _container
    }

    @Test
    func toggleFavoriteIsIdempotentWhenCalledTwice() async throws {
        let (vm, repo, _container) = try makeVM()
        let exercise = try #require(try await repo.all().first)
        await vm.load(id: exercise.id)
        let before = exercise.isFavorite

        await vm.toggleFavorite()
        await vm.toggleFavorite()

        let reloaded = try #require(try await repo.find(id: exercise.id))
        #expect(reloaded.isFavorite == before)
        _ = _container
    }

    @Test
    func toggleFavoriteDoesNothingWhenNotLoaded() async throws {
        let (vm, _, _container) = try makeVM()

        await vm.toggleFavorite()

        #expect(vm.errorMessage == nil)
        _ = _container
    }

    private func makeVM() throws -> (ExerciseDetailViewModel, SwiftDataExerciseRepository, ModelContainer) {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let repo = SwiftDataExerciseRepository(context: container.mainContext)
        return (ExerciseDetailViewModel(repository: repo), repo, container)
    }
}
