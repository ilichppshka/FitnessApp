import Foundation
import Observation

@Observable
final class ProfileSetupViewModel {
    static let minBodyWeight: Double = 30
    static let maxBodyWeight: Double = 200
    static let weightStep: Double = 0.5

    var name: String = ""
    var bodyWeightKg: Double = 75
    var selectedMascot: MascotOption = .athlete

    private(set) var isSaving: Bool = false
    private(set) var errorMessage: String?

    private let users: any UserRepository
    private let notifications: any NotificationScheduling
    private let onComplete: @MainActor () -> Void

    init(
        users: any UserRepository,
        notifications: any NotificationScheduling,
        onComplete: @escaping @MainActor () -> Void
    ) {
        self.users = users
        self.notifications = notifications
        self.onComplete = onComplete
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty
            && bodyWeightKg >= Self.minBodyWeight
            && bodyWeightKg <= Self.maxBodyWeight
            && !isSaving
    }

    var canDecrementWeight: Bool { bodyWeightKg > Self.minBodyWeight }
    var canIncrementWeight: Bool { bodyWeightKg < Self.maxBodyWeight }

    func decrementWeight() {
        bodyWeightKg = max(Self.minBodyWeight, bodyWeightKg - Self.weightStep)
    }

    func incrementWeight() {
        bodyWeightKg = min(Self.maxBodyWeight, bodyWeightKg + Self.weightStep)
    }

    func requestNotificationAuthorization() async {
        _ = try? await notifications.requestAuthorizationIfNeeded()
    }

    func save() async {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil

        do {
            let profile = try await users.current()
            profile.name = trimmedName
            profile.bodyWeight = bodyWeightKg
            profile.selectedMascotId = selectedMascot.rawValue
            try await users.update(profile)
            isSaving = false
            onComplete()
        } catch {
            errorMessage = String(localized: "profileSetup.error.generic")
            isSaving = false
        }
    }
}
