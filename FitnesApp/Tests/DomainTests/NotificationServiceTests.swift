@testable import FitnesApp
import Foundation
import Testing
import UserNotifications

struct NotificationServiceTests {
    @Test
    func requestAuthorizationPassesAlertAndSound() async throws {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)

        let granted = try await service.requestAuthorizationIfNeeded()

        #expect(granted == true)
        let options = try #require(center.requestedAuthorizationOptions.first)
        #expect(options.contains(.alert))
        #expect(options.contains(.sound))
    }

    @Test
    func requestAuthorizationPropagatesDeniedResult() async throws {
        let center = MockUserNotificationScheduler()
        center.authorizationResult = false
        let service = NotificationService(center: center)

        let granted = try await service.requestAuthorizationIfNeeded()

        #expect(granted == false)
    }

    @Test
    func scheduleRestEndCreatesRequestWithSessionScopedIdentifier() async throws {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)
        let sessionID = UUID()

        try await service.scheduleRestEnd(after: 90, sessionID: sessionID)

        let request = try #require(center.addedRequests.first)
        #expect(request.identifier == NotificationService.identifier(for: sessionID))
        #expect(request.content.title == "Отдых окончен")
        #expect(request.content.sound == .default)
        let trigger = try #require(request.trigger as? UNTimeIntervalNotificationTrigger)
        #expect(trigger.timeInterval == 90)
        #expect(trigger.repeats == false)
    }

    @Test
    func cancelRestEndRemovesSessionScopedIdentifier() async throws {
        let center = MockUserNotificationScheduler()
        let service = NotificationService(center: center)
        let sessionID = UUID()

        await service.cancelRestEnd(sessionID: sessionID)

        let removed = try #require(center.removedIdentifiers.first)
        #expect(removed == [NotificationService.identifier(for: sessionID)])
    }
}
