@testable import FitnesApp
import Foundation

@MainActor
final class MockUserRepository: UserRepository {
    var currentResult: UserProfile?
    var currentError: Error?
    var updateError: Error?

    private(set) var updateCalls: [UserProfile] = []

    func current() async throws -> UserProfile {
        if let currentError { throw currentError }
        return currentResult ?? UserProfile(name: "", bodyWeight: 0)
    }

    func update(_ profile: UserProfile) async throws {
        updateCalls.append(profile)
        if let updateError { throw updateError }
    }
}
