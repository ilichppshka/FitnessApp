@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct UserRepositoryTests {
    @Test
    func currentCreatesDefaultProfileIfMissing() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)

        let profile = try await repo.current()

        #expect(profile.name.isEmpty)
        #expect(profile.bodyWeight == 0)
        #expect(profile.selectedMascotId == "duck")
    }

    @Test
    func currentReturnsSameProfileOnSecondCall() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)

        let first = try await repo.current()
        let second = try await repo.current()

        #expect(first.id == second.id)
    }

    @Test
    func updatePersistsChanges() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)

        try await repo.update { profile in
            profile.name = "Илья"
            profile.bodyWeight = 75.5
        }

        let reloaded = try await repo.current()
        #expect(reloaded.name == "Илья")
        #expect(reloaded.bodyWeight == 75.5)
    }

    @Test
    func existsReturnsFalseWhenNoProfile() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)

        let result = try await repo.exists()

        #expect(!result)
    }

    @Test
    func existsReturnsTrueAfterCreating() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)

        _ = try await repo.current() // triggers default profile creation
        let result = try await repo.exists()

        #expect(result)
    }
}
