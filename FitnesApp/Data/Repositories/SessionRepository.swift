import Foundation
import SwiftData

protocol SessionRepository {
    func activeSession() async throws -> WorkoutSession?
    func create(planID: UUID?, title: String) async throws -> WorkoutSession
    @discardableResult
    func appendSet(_ draft: WorkoutSetDraft, to sessionID: UUID) async throws -> WorkoutSet
    func finish(_ sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO
    func discard(_ sessionID: UUID) async throws

    func history(range: ClosedRange<Date>) async throws -> [WorkoutSessionDTO]
    func find(id: UUID) async throws -> WorkoutSessionDTO?
    func lastSet(exerciseID: UUID) async throws -> WorkoutSetDTO?
    func clearHistory() async throws
}

final class SwiftDataSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func activeSession() async throws -> WorkoutSession? {
        try fetchActiveSessionModel()
    }

    func create(planID: UUID?, title: String) async throws -> WorkoutSession {
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
        let sessionTitle = title.isEmpty ? (plan?.name ?? "Quick Workout") : title
        let session = WorkoutSession(title: sessionTitle, plan: plan, startedAt: Date())
        context.insert(session)
        try context.save()
        return session
    }

    func appendSet(_ draft: WorkoutSetDraft, to sessionID: UUID) async throws -> WorkoutSet {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw WorkoutError.sessionNotFound(id: sessionID)
        }
        guard let exercise = try fetchExerciseModel(id: draft.exerciseID) else {
            throw DataError.exerciseNotFound(id: draft.exerciseID)
        }
        let setNumber = session.sets
            .filter { $0.exercise?.id == draft.exerciseID }
            .count + 1
        let set = WorkoutSet(
            session: session,
            exercise: exercise,
            setNumber: setNumber,
            weight: draft.weight,
            reps: draft.reps,
            loggedAt: Date()
        )
        set.tonnage = draft.tonnage
        context.insert(set)
        session.totalTonnage += draft.tonnage
        try context.save()
        return set
    }

    func finish(_ sessionID: UUID, at date: Date) async throws -> WorkoutSessionDTO {
        guard let session = try fetchSessionModel(id: sessionID) else {
            throw WorkoutError.sessionNotFound(id: sessionID)
        }
        session.finishedAt = date
        try context.save()
        return session.toDTO()
    }

    func discard(_ sessionID: UUID) async throws {
        guard let session = try fetchSessionModel(id: sessionID) else { return }
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

    func find(id: UUID) async throws -> WorkoutSessionDTO? {
        try fetchSessionModel(id: id)?.toDTO()
    }

    func lastSet(exerciseID: UUID) async throws -> WorkoutSetDTO? {
        let descriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate { $0.exercise != nil },
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        let sets = try context.fetch(descriptor)
        return sets.first(where: { $0.exercise?.id == exerciseID })?.toDTO()
    }

    func clearHistory() async throws {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.finishedAt != nil }
        )
        let finished = try context.fetch(descriptor)
        for session in finished {
            context.delete(session)
        }
        try context.save()
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
