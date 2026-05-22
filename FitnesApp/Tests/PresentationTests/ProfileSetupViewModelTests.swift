@testable import FitnesApp
import Foundation
import SwiftData
import Testing

@MainActor
struct ProfileSetupViewModelTests {
    @Test
    func saveCreatesUserProfileWithTrimmedNameAndPersistsFields() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)
        let notifications = MockNotificationScheduling()
        let completion = CompletionTracker()

        let viewModel = ProfileSetupViewModel(
            users: repo,
            notifications: notifications,
            onComplete: { completion.called = true }
        )
        viewModel.name = "  Илья  "
        viewModel.bodyWeightKg = 78
        viewModel.selectedMascot = .runner

        #expect(viewModel.canSave)

        await viewModel.save()

        let profile = try await repo.current()
        #expect(profile.name == "Илья")
        #expect(profile.bodyWeight == 78)
        #expect(profile.selectedMascotId == "runner")
        #expect(completion.called)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func saveIsBlockedWhenNameIsBlank() async throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)
        let notifications = MockNotificationScheduling()
        let completion = CompletionTracker()

        let viewModel = ProfileSetupViewModel(
            users: repo,
            notifications: notifications,
            onComplete: { completion.called = true }
        )
        viewModel.name = "   "
        viewModel.bodyWeightKg = 75

        #expect(!viewModel.canSave)

        await viewModel.save()

        let profile = try await repo.current()
        #expect(profile.name.isEmpty)
        #expect(!completion.called)
    }

    @Test
    func weightSteppersClampToBounds() throws {
        let container = try InMemoryContainer.make()
        let repo = SwiftDataUserRepository(context: container.mainContext)
        let viewModel = ProfileSetupViewModel(
            users: repo,
            notifications: MockNotificationScheduling(),
            onComplete: {}
        )

        viewModel.bodyWeightKg = ProfileSetupViewModel.minBodyWeight
        viewModel.decrementWeight()
        #expect(viewModel.bodyWeightKg == ProfileSetupViewModel.minBodyWeight)
        #expect(!viewModel.canDecrementWeight)

        viewModel.bodyWeightKg = ProfileSetupViewModel.maxBodyWeight
        viewModel.incrementWeight()
        #expect(viewModel.bodyWeightKg == ProfileSetupViewModel.maxBodyWeight)
        #expect(!viewModel.canIncrementWeight)
    }

    @Test
    func requestNotificationAuthorizationDelegatesToService() async throws {
        let container = try InMemoryContainer.make()
        let notifications = MockNotificationScheduling()
        let viewModel = ProfileSetupViewModel(
            users: SwiftDataUserRepository(context: container.mainContext),
            notifications: notifications,
            onComplete: {}
        )

        await viewModel.requestNotificationAuthorization()

        #expect(notifications.requestAuthorizationCallCount == 1)
    }
}

@MainActor
private final class CompletionTracker {
    var called = false
}
