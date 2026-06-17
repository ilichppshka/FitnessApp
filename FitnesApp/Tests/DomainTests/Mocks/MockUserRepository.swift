@testable import FitnesApp
import Foundation

@MainActor
final class MockUserRepository: UserRepository {
    var currentResult: UserProfile?
    var currentError: Error?
    var updateError: Error?
    var existsResult: Bool = false

    private(set) var updateCallCount = 0

    func current() async throws -> UserProfile {
        if let currentError { throw currentError }
        if let currentResult { return currentResult }
        return UserProfile(name: "", bodyWeight: 0)
    }

    func update(_ mutate: @MainActor (UserProfile) -> Void) async throws {
        updateCallCount += 1
        if let updateError { throw updateError }
        let profile = try await current()
        mutate(profile)
    }

    func exists() async throws -> Bool {
        existsResult
    }
}
