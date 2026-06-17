import Foundation
import Observation

@MainActor
@Observable
final class ExerciseLibraryViewModel {
    var searchQuery: String = ""
    var selectedMuscleGroupID: UUID?

    private(set) var exercises: [Exercise] = []
    private(set) var muscleGroups: [MuscleGroupChip] = []
    private(set) var totalCount: Int = 0
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let repository: any ExerciseRepository

    init(repository: any ExerciseRepository) {
        self.repository = repository
    }

    var searchTrigger: String {
        "\(searchQuery)|\(selectedMuscleGroupID?.uuidString ?? "")"
    }

    var hasActiveFilter: Bool {
        !searchQuery.isEmpty || selectedMuscleGroupID != nil
    }

    func loadInitial() async {
        isLoading = true
        errorMessage = nil
        do {
            let all = try await repository.all()
            let groups = try await repository.muscleGroups()
            totalCount = all.count
            muscleGroups = groups.map { group in
                let count = all.reduce(into: 0) { acc, exercise in
                    if exercise.primaryMuscles.contains(where: { $0.id == group.id }) ||
                        exercise.secondaryMuscles.contains(where: { $0.id == group.id }) {
                        acc += 1
                    }
                }
                let name = NSLocalizedString("muscle.\(group.slug)", tableName: "Exercises", comment: "")
                return MuscleGroupChip(id: group.id, name: name, count: count)
            }
            exercises = all
            isLoading = false
        } catch {
            errorMessage = String(localized: "library.error.generic")
            isLoading = false
        }
    }

    func reload() async {
        errorMessage = nil
        do {
            let muscleIDs = selectedMuscleGroupID.map { [$0] } ?? []
            exercises = try await repository.search(query: searchQuery, muscleGroupIDs: muscleIDs)
        } catch {
            errorMessage = String(localized: "library.error.generic")
        }
    }

    func selectGroup(_ id: UUID?) {
        if let id, selectedMuscleGroupID == id {
            selectedMuscleGroupID = nil
        } else {
            selectedMuscleGroupID = id
        }
    }

    func exercise(id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }
}

struct MuscleGroupChip: Identifiable, Hashable {
    let id: UUID
    let name: String
    let count: Int
}
