import Foundation

protocol NotificationScheduling: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleRestEnd(after seconds: TimeInterval, soundEnabled: Bool) async throws
    func cancelRestEnd() async
}
