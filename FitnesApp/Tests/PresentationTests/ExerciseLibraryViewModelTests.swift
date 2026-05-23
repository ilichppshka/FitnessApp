@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct ExerciseLibraryViewModelTests {
    @Test
    func loadInitial_populatesExercisesAndMuscleGroupsAndTotalCount() async throws {
        let (vm, _container) = try makeVM()

        await vm.loadInitial()

        #expect(!vm.exercises.isEmpty)
        #expect(vm.totalCount == vm.exercises.count)
        #expect(!vm.muscleGroups.isEmpty)
        #expect(vm.muscleGroups.map(\.name) == vm.muscleGroups.map(\.name).sorted())
        for group in vm.muscleGroups {
            let expected = vm.exercises.filter { $0.muscleGroups.contains { $0.id == group.id } }.count
            #expect(group.count == expected)
        }
        _ = _container
    }

    @Test
    func selectGroup_filtersExercisesToThatGroup() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        await vm.reload()

        #expect(!vm.exercises.isEmpty)
        #expect(vm.exercises.allSatisfy { $0.muscleGroups.contains { $0.id == group.id } })
        _ = _container
    }

    @Test
    func selectGroup_nil_clearsFilter() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let total = vm.exercises.count
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        await vm.reload()
        vm.selectGroup(nil)
        await vm.reload()

        #expect(vm.exercises.count == total)
        #expect(vm.selectedMuscleGroupID == nil)
        _ = _container
    }

    @Test
    func selectGroup_tapSameGroup_clearsSelection() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        vm.selectGroup(group.id)

        #expect(vm.selectedMuscleGroupID == nil)
        _ = _container
    }

    @Test
    func searchQuery_filtersBySubstringCaseInsensitive() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()

        vm.searchQuery = "жим"
        await vm.reload()

        #expect(!vm.exercises.isEmpty)
        #expect(vm.exercises.allSatisfy { $0.name.localizedStandardContains("жим") })
        _ = _container
    }

    @Test
    func searchQuery_combinedWithMuscleGroup_appliesBothFilters() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let group = try #require(vm.muscleGroups.first)

        vm.selectGroup(group.id)
        vm.searchQuery = "жим"
        await vm.reload()

        #expect(vm.exercises.allSatisfy {
            $0.name.localizedStandardContains("жим") &&
            $0.muscleGroups.contains { $0.id == group.id }
        })
        _ = _container
    }

    @Test
    func searchQuery_noMatch_resultsEmptyButTotalCountUnchanged() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let total = vm.totalCount

        vm.searchQuery = "qwerty_no_match_xyz"
        await vm.reload()

        #expect(vm.exercises.isEmpty)
        #expect(vm.totalCount == total)
        _ = _container
    }

    @Test
    func exerciseLookup_returnsLoadedExerciseOrNil() async throws {
        let (vm, _container) = try makeVM()
        await vm.loadInitial()
        let known = try #require(vm.exercises.first)

        #expect(vm.exercise(id: known.id)?.id == known.id)
        #expect(vm.exercise(id: UUID()) == nil)
        _ = _container
    }

    // MARK: - Helpers

    private func makeVM() throws -> (ExerciseLibraryViewModel, ModelContainer) {
        let container = try InMemoryContainer.make()
        try DataSeeder.seedIfNeeded(container.mainContext)
        let repo = SwiftDataExerciseRepository(context: container.mainContext)
        return (ExerciseLibraryViewModel(repository: repo), container)
    }
}
