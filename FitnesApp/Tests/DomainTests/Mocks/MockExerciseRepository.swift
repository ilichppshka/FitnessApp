@testable import FitnesApp
import Foundation

@MainActor
final class MockExerciseRepository: ExerciseRepository {
    var bestPRResult: PersonalRecordDTO?
    var addPRResult: PersonalRecordDTO?
    var addPRError: Error?

    private(set) var bestPRCalls: [UUID] = []
    private(set) var addPRCalls: [(exerciseID: UUID, weight: Double, reps: Int, date: Date)] = []

    func all() async throws -> [Exercise] { [] }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] { [] }

    func find(id: UUID) async throws -> Exercise? { nil }

    func allMuscleGroups() async throws -> [MuscleGroup] { [] }

    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO? {
        bestPRCalls.append(exerciseID)
        return bestPRResult
    }

    func personalRecordHistory(exerciseID: UUID) async throws -> [PersonalRecordDTO] { [] }

    private(set) var setFavoriteCalls: [(id: UUID, isFavorite: Bool)] = []

    func setFavorite(id: UUID, isFavorite: Bool) async throws {
        setFavoriteCalls.append((id, isFavorite))
    }

    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO {
        addPRCalls.append((exerciseID, weight, reps, date))
        if let addPRError { throw addPRError }
        if let addPRResult { return addPRResult }
        return PersonalRecordDTO(
            id: UUID(),
            exerciseID: exerciseID,
            exerciseName: "mock",
            date: date,
            weight: weight,
            reps: reps,
            tonnage: weight * Double(reps)
        )
    }
}
