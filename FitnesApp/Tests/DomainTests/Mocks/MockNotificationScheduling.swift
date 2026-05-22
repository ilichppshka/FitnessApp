@testable import FitnesApp
import Foundation

final class MockNotificationScheduling: NotificationScheduling, @unchecked Sendable {
    var authorizationResult: Bool = true
    var authorizationError: Error?
    private(set) var requestAuthorizationCallCount = 0
    private(set) var scheduledRequests: [(seconds: TimeInterval, sessionID: UUID)] = []
    private(set) var cancelledSessionIDs: [UUID] = []

    func requestAuthorizationIfNeeded() async throws -> Bool {
        requestAuthorizationCallCount += 1
        if let authorizationError {
            throw authorizationError
        }
        return authorizationResult
    }

    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws {
        scheduledRequests.append((seconds, sessionID))
    }

    func cancelRestEnd(sessionID: UUID) async {
        cancelledSessionIDs.append(sessionID)
    }
}
