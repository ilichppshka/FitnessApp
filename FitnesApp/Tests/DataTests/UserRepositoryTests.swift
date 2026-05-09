@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct UserRepositoryTests {
    @Test
    func currentCreatesDefaultProfileIfMissing() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataUserRepository(context: context)

        let profile = try await repo.current()

        #expect(profile.name.isEmpty)
        #expect(profile.bodyWeight == 0)
        #expect(profile.selectedMascotId == "default")
    }

    @Test
    func currentReturnsSameProfileOnSecondCall() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataUserRepository(context: context)

        let first = try await repo.current()
        let second = try await repo.current()

        #expect(first.id == second.id)
    }

    @Test
    func updatePersistsChanges() async throws {
        let container = try InMemoryContainer.make()
        let context = container.mainContext
        let repo = SwiftDataUserRepository(context: context)
        let profile = try await repo.current()

        profile.name = "Илья"
        profile.bodyWeight = 75.5
        try await repo.update(profile)

        let reloaded = try await repo.current()
        #expect(reloaded.name == "Илья")
        #expect(reloaded.bodyWeight == 75.5)
    }
}
