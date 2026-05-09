import Foundation
import SwiftData

protocol SessionRepository {
    func activeSession() async throws -> WorkoutSession?
    func create(planID: UUID?) async throws -> WorkoutSession
    func addSet(_ set: WorkoutSet, to session: WorkoutSession) async throws
    func finish(_ session: WorkoutSession, at date: Date) async throws
    func history(range: ClosedRange<Date>) async throws -> [WorkoutSession]
    func byID(_ id: UUID) async throws -> WorkoutSession?
}

final class SwiftDataSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func activeSession() async throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.finishedAt == nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func create(planID: UUID?) async throws -> WorkoutSession {
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
        return session
    }

    func addSet(_ set: WorkoutSet, to session: WorkoutSession) async throws {
        set.session = session
        if set.modelContext == nil {
            context.insert(set)
        }
        try context.save()
    }

    func finish(_ session: WorkoutSession, at date: Date) async throws {
        session.finishedAt = date
        try context.save()
    }

    func history(range: ClosedRange<Date>) async throws -> [WorkoutSession] {
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
        return try context.fetch(descriptor)
    }

    func byID(_ id: UUID) async throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
