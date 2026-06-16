import Foundation
import SwiftData

protocol UserRepository {
    func current() async throws -> UserProfile
    func update(_ profile: UserProfile) async throws
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

    func update(_ profile: UserProfile) async throws {
        if profile.modelContext == nil {
            context.insert(profile)
        }
        try context.save()
    }
}
