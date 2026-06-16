@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct ExerciseLibraryViewModelTests {
    @Test
    func loadInitial_populatesExercisesAndMuscleGroupsAndTotalCount() async throws {
        let (vm, container) = try makeVM()

        await vm.loadInitial()

        #expect(!vm.exercises.isEmpty)
        #expect(vm.totalCount == vm.exercises.count)
        #expect(!vm.muscleGroups.isEmpty)
        #expect(!vm.muscleGroups.isEmpty)
        for group in vm.muscleGroups {
            let expected = vm.exercises.filter { exercise in
                exercise.primaryMuscles.contains { $0.id == group.id } ||
                exercise.secondaryMuscles.contains { $0.id == group.id }
            }.count
            #expect(group.count == expected)
        }
        _ = container
    }

    @Test
    func selectGroup_filtersExercisesToThatGroup() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        await vm.reload()

        #expect(!vm.exercises.isEmpty)
        #expect(vm.exercises.allSatisfy { exercise in
            exercise.primaryMuscles.contains { $0.id == group.id } ||
            exercise.secondaryMuscles.contains { $0.id == group.id }
        })
        _ = container
    }

    @Test
    func selectGroup_nil_clearsFilter() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let total = vm.exercises.count
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        await vm.reload()
        vm.selectGroup(nil)
        await vm.reload()

        #expect(vm.exercises.count == total)
        #expect(vm.selectedMuscleGroupID == nil)
        _ = container
    }

    @Test
    func selectGroup_tapSameGroup_clearsSelection() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        vm.selectGroup(group.id)

        #expect(vm.selectedMuscleGroupID == nil)
        _ = container
    }

    @Test
    func searchQuery_emptyReturnsAll() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let total = vm.totalCount

        vm.searchQuery = ""
        await vm.reload()

        #expect(vm.exercises.count == total)
        _ = container
    }

    @Test
    func searchQuery_noMatch_resultsEmpty() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()

        vm.searchQuery = "xyz_impossible_xqz_123"
        await vm.reload()

        #expect(vm.exercises.isEmpty)
        _ = container
    }

    @Test
    func searchQuery_noMatch_totalCountUnchanged() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let total = vm.totalCount

        vm.searchQuery = "xyz_impossible_xqz_123"
        await vm.reload()

        #expect(vm.totalCount == total)
        _ = container
    }

    @Test
    func searchQuery_combinedWithMuscleGroup_muscleFilterStillApplied() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        vm.searchQuery = "xyz_impossible_xqz_123"
        await vm.reload()

        #expect(vm.exercises.isEmpty)
        _ = container
    }

    @Test
    func exerciseLookup_returnsLoadedExerciseOrNil() async throws {
        let (vm, container) = try makeVM()
        await vm.loadInitial()
        let known = try #require(vm.exercises.first)

        #expect(vm.exercise(id: known.id)?.id == known.id)
        #expect(vm.exercise(id: UUID()) == nil)
        _ = container
    }

    // MARK: - Helpers

    private func makeVM() throws -> (ExerciseLibraryViewModel, ModelContainer) {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let repo = SwiftDataExerciseRepository(context: container.mainContext)
        return (ExerciseLibraryViewModel(repository: repo), container)
    }
}
