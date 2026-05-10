@testable import FitnesApp
import Foundation
import UserNotifications

final class MockUserNotificationScheduler: UserNotificationScheduler, @unchecked Sendable {
    var authorizationResult: Bool = true
    var authorizationError: Error?
    var addError: Error?

    private(set) var requestedAuthorizationOptions: [UNAuthorizationOptions] = []
    private(set) var addedRequests: [UNNotificationRequest] = []
    private(set) var removedIdentifiers: [[String]] = []

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestedAuthorizationOptions.append(options)
        if let authorizationError { throw authorizationError }
        return authorizationResult
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
        if let addError { throw addError }
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(identifiers)
    }
}
