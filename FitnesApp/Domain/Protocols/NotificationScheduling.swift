import Foundation

protocol NotificationScheduling: Sendable {
    func requestAuthorizationIfNeeded() async throws -> Bool
    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws
    func cancelRestEnd(sessionID: UUID) async
}
