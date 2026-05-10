import Foundation
import UserNotifications

final class NotificationService: NotificationScheduling {
    private let center: UserNotificationScheduler

    init(center: UserNotificationScheduler = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorizationIfNeeded() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Отдых окончен"
        content.body = "Пора к следующему сету"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.identifier(for: sessionID),
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelRestEnd(sessionID: UUID) async {
        center.removePendingNotificationRequests(
            withIdentifiers: [Self.identifier(for: sessionID)]
        )
    }

    static func identifier(for sessionID: UUID) -> String {
        "rest-\(sessionID.uuidString)"
    }
}
