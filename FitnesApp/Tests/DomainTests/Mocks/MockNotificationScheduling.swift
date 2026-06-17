@testable import FitnesApp
import Foundation

final class MockNotificationScheduling: NotificationScheduling, @unchecked Sendable {
    var authorizationResult: Bool = true
    private(set) var requestAuthorizationCallCount = 0
    struct ScheduledRequest: Sendable {
        let seconds: TimeInterval
        let soundEnabled: Bool
    }

    private(set) var scheduledRequests: [ScheduledRequest] = []
    private(set) var cancelCallCount = 0

    func requestAuthorization() async -> Bool {
        requestAuthorizationCallCount += 1
        return authorizationResult
    }

    func scheduleRestEnd(after seconds: TimeInterval, soundEnabled: Bool) async throws {
        scheduledRequests.append(ScheduledRequest(seconds: seconds, soundEnabled: soundEnabled))
    }

    func cancelRestEnd() async {
        cancelCallCount += 1
    }
}
