import Foundation
import UserNotifications

final class NotificationService: NotificationScheduling {
    private static let restIdentifier = "com.fitnesapp.rest-timer"

    private let center: UserNotificationScheduler

    init(center: UserNotificationScheduler = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func scheduleRestEnd(after seconds: TimeInterval, soundEnabled: Bool) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Отдых окончен"
        content.body = "Пора к следующему сету"
        content.sound = soundEnabled ? .default : nil
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.restIdentifier,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelRestEnd() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.restIdentifier])
    }
}
