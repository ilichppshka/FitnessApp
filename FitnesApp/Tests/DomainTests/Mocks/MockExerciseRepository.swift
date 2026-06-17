@testable import FitnesApp
import Foundation

@MainActor
final class MockExerciseRepository: ExerciseRepository {
    var bestPRResult: PersonalRecordDTO?
    var addPRResult: PersonalRecordDTO?
    var addPRError: Error?
    var lastSetExercise: Exercise?

    private(set) var bestPRCalls: [UUID] = []
    struct AddPRCall {
        let exerciseID: UUID
        let weight: Double
        let reps: Int
        let date: Date
    }

    private(set) var addPRCalls: [AddPRCall] = []
    private(set) var setFavoriteCalls: [(exerciseID: UUID, value: Bool)] = []
    private(set) var findCalls: [UUID] = []

    func all() async throws -> [Exercise] { [] }

    func muscleGroups() async throws -> [MuscleGroup] { [] }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] { [] }

    func find(id: UUID) async throws -> Exercise? {
        findCalls.append(id)
        return lastSetExercise
    }

    func exerciseOfTheDay() async throws -> Exercise? { nil }

    func recent(limit: Int) async throws -> [Exercise] { [] }

    func favorites() async throws -> [Exercise] { [] }

    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws {
        setFavoriteCalls.append((exerciseID, value))
    }

    func personalRecords(exerciseID: UUID) async throws -> [PersonalRecord] { [] }

    func bestPersonalRecord(exerciseID: UUID) async throws -> PersonalRecordDTO? {
        bestPRCalls.append(exerciseID)
        return bestPRResult
    }

    func addPersonalRecord(
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        date: Date
    ) async throws -> PersonalRecordDTO {
        addPRCalls.append(AddPRCall(exerciseID: exerciseID, weight: weight, reps: reps, date: date))
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
