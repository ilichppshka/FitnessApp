import Foundation
import SwiftData

protocol ExerciseRepository {
    func all() async throws -> [Exercise]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?
    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO?
    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO
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

    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO? {
        guard let exercise = try await find(id: exerciseID) else { return nil }
        return exercise.personalRecords.max(by: { $0.weight < $1.weight })?.toDTO()
    }

    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO {
        guard let exercise = try await find(id: exerciseID) else {
            throw AppError.exerciseNotFound(id: exerciseID)
        }
        let record = PersonalRecord(
            exercise: exercise,
            date: date,
            weight: weight,
            reps: reps
        )
        context.insert(record)
        try context.save()
        return record.toDTO()
    }
}
