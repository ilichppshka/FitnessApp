import Foundation
import SwiftData

protocol ExerciseRepository {
    func all() async throws -> [Exercise]
    func muscleGroups() async throws -> [MuscleGroup]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?

    func exerciseOfTheDay() async throws -> Exercise?
    func recent(limit: Int) async throws -> [Exercise]

    func favorites() async throws -> [Exercise]
    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws

    func personalRecords(exerciseID: UUID) async throws -> [PersonalRecord]
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
        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        return exercises.sorted { localizedExerciseName($0) < localizedExerciseName($1) }
    }

    func muscleGroups() async throws -> [MuscleGroup] {
        let groups = try context.fetch(FetchDescriptor<MuscleGroup>())
        return groups.sorted { $0.displayOrder < $1.displayOrder }
    }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] {
        let all = try context.fetch(FetchDescriptor<Exercise>())
        let nameFiltered: [Exercise]
        if query.isEmpty {
            nameFiltered = all
        } else {
            nameFiltered = all.filter { exercise in
                localizedExerciseName(exercise).localizedStandardContains(query)
            }
        }
        let sorted = nameFiltered.sorted { localizedExerciseName($0) < localizedExerciseName($1) }
        guard !muscleGroupIDs.isEmpty else { return sorted }
        return sorted.filter { exercise in
            exercise.muscleLinks.contains { link in
                guard let groupID = link.muscleGroup?.id else { return false }
                return muscleGroupIDs.contains(groupID)
            }
        }
    }

    func find(id: UUID) async throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func exerciseOfTheDay() async throws -> Exercise? {
        let exercises = try await all()
        guard !exercises.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        return exercises[dayOfYear % exercises.count]
    }

    func recent(limit: Int) async throws -> [Exercise] {
        guard limit > 0 else { return [] }
        let sets = try context.fetch(
            FetchDescriptor<WorkoutSet>(sortBy: [SortDescriptor(\.loggedAt, order: .reverse)])
        )
        var seen = Set<UUID>()
        var result: [Exercise] = []
        for set in sets {
            guard let exercise = set.exercise, !seen.contains(exercise.id) else { continue }
            seen.insert(exercise.id)
            result.append(exercise)
            if result.count >= limit { break }
        }
        return result
    }

    func favorites() async throws -> [Exercise] {
        let all = try context.fetch(FetchDescriptor<Exercise>())
        return all.filter(\.isFavorite).sorted { localizedExerciseName($0) < localizedExerciseName($1) }
    }

    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws {
        guard let exercise = try await find(id: exerciseID) else {
            throw DataError.exerciseNotFound(id: exerciseID)
        }
        exercise.isFavorite = value
        try context.save()
    }

    func personalRecords(exerciseID: UUID) async throws -> [PersonalRecord] {
        guard let exercise = try await find(id: exerciseID) else { return [] }
        return exercise.personalRecords.sorted { $0.date > $1.date }
    }

    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO? {
        guard let exercise = try await find(id: exerciseID) else { return nil }
        return exercise.personalRecords
            .max(by: { lhs, rhs in
                OneRepMaxCalculator.epley(weight: lhs.weight, reps: lhs.reps) <
                OneRepMaxCalculator.epley(weight: rhs.weight, reps: rhs.reps)
            })?
            .toDTO()
    }

    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO {
        guard let exercise = try await find(id: exerciseID) else {
            throw DataError.exerciseNotFound(id: exerciseID)
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

    // MARK: - Deprecated aliases kept for test compatibility during migration

    func allMuscleGroups() async throws -> [MuscleGroup] {
        try await muscleGroups()
    }

    func setFavorite(id: UUID, isFavorite: Bool) async throws {
        try await setFavorite(id, isFavorite)
    }

    private func localizedExerciseName(_ exercise: Exercise) -> String {
        NSLocalizedString("exercise.\(exercise.slug).name", comment: "")
    }
}
