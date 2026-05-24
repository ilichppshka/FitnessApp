import Foundation
import SwiftData

protocol ExerciseRepository {
    func all() async throws -> [Exercise]
    func allMuscleGroups() async throws -> [MuscleGroup]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?
    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO?
    func personalRecordHistory(exerciseID: UUID) async throws -> [PersonalRecordDTO]
    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO
    func setFavorite(id: UUID, isFavorite: Bool) async throws
}

final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() async throws -> [Exercise] {
        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        return exercises.sorted { localizedExerciseName($0) < localizedExerciseName($1) }
    }

    func allMuscleGroups() async throws -> [MuscleGroup] {
        let groups = try context.fetch(FetchDescriptor<MuscleGroup>())
        return groups.sorted { localizedMuscleName($0) < localizedMuscleName($1) }
    }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] {
        let all = try context.fetch(FetchDescriptor<Exercise>())
        let nameFiltered: [Exercise]
        if query.isEmpty {
            nameFiltered = all
        } else {
            nameFiltered = all.filter {
                localizedExerciseName($0).localizedStandardContains(query)
            }
        }
        let sorted = nameFiltered.sorted { localizedExerciseName($0) < localizedExerciseName($1) }
        guard !muscleGroupIDs.isEmpty else { return sorted }
        return sorted.filter { exercise in
            exercise.primaryMuscleGroups.contains { muscleGroupIDs.contains($0.id) } ||
            exercise.secondaryMuscleGroups.contains { muscleGroupIDs.contains($0.id) }
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

    func personalRecordHistory(exerciseID: UUID) async throws -> [PersonalRecordDTO] {
        guard let exercise = try await find(id: exerciseID) else { return [] }
        return exercise.personalRecords
            .sorted { $0.date > $1.date }
            .map { $0.toDTO() }
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

    func setFavorite(id: UUID, isFavorite: Bool) async throws {
        guard let exercise = try await find(id: id) else {
            throw AppError.exerciseNotFound(id: id)
        }
        exercise.isFavorite = isFavorite
        try context.save()
    }

    private func localizedExerciseName(_ exercise: Exercise) -> String {
        NSLocalizedString("exercise.\(exercise.slug).name", comment: "")
    }

    private func localizedMuscleName(_ group: MuscleGroup) -> String {
        NSLocalizedString("muscle.\(group.slug)", comment: "")
    }
}
