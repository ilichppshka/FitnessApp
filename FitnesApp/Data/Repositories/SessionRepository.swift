import Foundation
import SwiftData

protocol SessionRepository {
    func activeSession() async throws -> WorkoutSessionDTO?
    func create(planID: UUID?) async throws -> WorkoutSessionDTO
    func addSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        tonnage: Double
    ) async throws -> WorkoutSetDTO
    func bumpTotalTonnage(sessionID: UUID, by delta: Double) async throws
    func finish(sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO
    func delete(sessionID: UUID) async throws
    func history(range: ClosedRange<Date>) async throws -> [WorkoutSessionDTO]
    func byID(_ id: UUID) async throws -> WorkoutSessionDTO?
}

final class SwiftDataSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func activeSession() async throws -> WorkoutSessionDTO? {
        try fetchActiveSessionModel()?.toDTO()
    }

    func create(planID: UUID?) async throws -> WorkoutSessionDTO {
        let plan: WorkoutPlan?
        if let planID {
            var descriptor = FetchDescriptor<WorkoutPlan>(
                predicate: #Predicate { $0.id == planID }
            )
            descriptor.fetchLimit = 1
            plan = try context.fetch(descriptor).first
        } else {
            plan = nil
        }
        let session = WorkoutSession(plan: plan, startedAt: Date())
        context.insert(session)
        try context.save()
        return session.toDTO()
    }

    func addSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int,
        tonnage: Double
    ) async throws -> WorkoutSetDTO {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw AppError.sessionNotFound(id: sessionID)
        }
        guard let exercise = try fetchExerciseModel(id: exerciseID) else {
            throw AppError.exerciseNotFound(id: exerciseID)
        }
        let setNumber = session.sets
            .filter { $0.exercise.id == exerciseID }
            .count + 1
        let set = WorkoutSet(
            session: session,
            exercise: exercise,
            setNumber: setNumber,
            weight: weight,
            reps: reps,
            loggedAt: Date()
        )
        set.tonnage = tonnage
        context.insert(set)
        try context.save()
        return set.toDTO()
    }

    func bumpTotalTonnage(sessionID: UUID, by delta: Double) async throws {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw AppError.sessionNotFound(id: sessionID)
        }
        session.totalTonnage += delta
        try context.save()
    }

    func finish(sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw AppError.sessionNotFound(id: sessionID)
        }
        session.finishedAt = date
        try context.save()
        return session.toDTO()
    }

    func delete(sessionID: UUID) async throws {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw AppError.sessionNotFound(id: sessionID)
        }
        context.delete(session)
        try context.save()
    }

    func history(range: ClosedRange<Date>) async throws -> [WorkoutSessionDTO] {
        let lower = range.lowerBound
        let upper = range.upperBound
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { session in
                session.finishedAt != nil
                    && session.startedAt >= lower
                    && session.startedAt <= upper
            },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDTO() }
    }

    func byID(_ id: UUID) async throws -> WorkoutSessionDTO? {
        try fetchSessionModel(id: id)?.toDTO()
    }

    // MARK: - Internal helpers

    private func fetchActiveSessionModel() throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.finishedAt == nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func fetchSessionModel(id: UUID) throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func fetchExerciseModel(id: UUID) throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
