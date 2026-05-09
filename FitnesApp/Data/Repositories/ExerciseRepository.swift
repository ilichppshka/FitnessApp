import Foundation
import SwiftData

protocol ExerciseRepository {
    func all() async throws -> [Exercise]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?
}

final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] {
        var descriptor = FetchDescriptor<Exercise>()
        if !query.isEmpty {
            descriptor.predicate = #Predicate { $0.name.localizedStandardContains(query) }
        }
        descriptor.sortBy = [SortDescriptor(\.name)]
        let result = try context.fetch(descriptor)
        guard !muscleGroupIDs.isEmpty else { return result }
        return result.filter { exercise in
            exercise.muscleGroups.contains { muscleGroupIDs.contains($0.id) }
        }
    }

    func find(id: UUID) async throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
