import Foundation
import SwiftData

protocol UserRepository {
    func current() async throws -> UserProfile
    func update(_ mutate: @MainActor (UserProfile) -> Void) async throws
    func exists() async throws -> Bool
}

final class SwiftDataUserRepository: UserRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func current() async throws -> UserProfile {
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let profile = UserProfile(
            name: "",
            bodyWeight: 0,
            weightUnit: .kg,
            selectedMascotId: "duck",
            defaultRestDuration: 120,
            autoStartRestTimer: true,
            createdAt: .now
        )
        context.insert(profile)
        try context.save()
        return profile
    }

    func update(_ mutate: @MainActor (UserProfile) -> Void) async throws {
        let profile = try await current()
        mutate(profile)
        try context.save()
    }

    func exists() async throws -> Bool {
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1
        return try !context.fetch(descriptor).isEmpty
    }
}
