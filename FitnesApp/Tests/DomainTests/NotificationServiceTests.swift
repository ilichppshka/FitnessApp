@testable import FitnesApp
import Foundation
import Testing
import UserNotifications

struct NotificationServiceTests {
    @Test
    func requestAuthorizationPassesAlertAndSound() async {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)

        let granted = await service.requestAuthorization()

        #expect(granted == true)
        let options = try? #require(center.requestedAuthorizationOptions.first)
        #expect(options?.contains(.alert) == true)
        #expect(options?.contains(.sound) == true)
    }

    @Test
    func requestAuthorizationReturnsFalseWhenDenied() async {
        let center = MockUserNotificationScheduler()
        center.authorizationResult = false
        let service = NotificationService(center: center)

        let granted = await service.requestAuthorization()

        #expect(granted == false)
    }

    @Test
    func scheduleRestEndCreatesRequestWithFixedIdentifier() async throws {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)

        try await service.scheduleRestEnd(after: 90, soundEnabled: true)

        let request = try #require(center.addedRequests.first)
        #expect(request.content.title == "Отдых окончен")
        #expect(request.content.sound == .default)
        let trigger = try #require(request.trigger as? UNTimeIntervalNotificationTrigger)
        #expect(trigger.timeInterval == 90)
        #expect(trigger.repeats == false)
    }

    @Test
    func scheduleRestEndWithSoundDisabledOmitsSound() async throws {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)

        try await service.scheduleRestEnd(after: 60, soundEnabled: false)

        let request = try #require(center.addedRequests.first)
        #expect(request.content.sound == nil)
    }

    @Test
    func cancelRestEndRemovesFixedIdentifier() async {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)

        await service.cancelRestEnd()

        #expect(center.removedIdentifiers.count == 1)
    }
}
