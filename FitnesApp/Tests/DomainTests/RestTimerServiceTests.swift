@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct RestTimerServiceTests {
    private final class Clock {
        var current: Date
        init(_ date: Date = Date(timeIntervalSince1970: 1_000_000)) { self.current = date }
        func now() -> Date { current }
        func advance(by seconds: TimeInterval) { current = current.addingTimeInterval(seconds) }
    }

    private func makeService(
        clock: Clock = Clock(),
        notifications: MockNotificationScheduling = MockNotificationScheduling(),
        haptics: MockHapticsService = MockHapticsService()
    ) -> RestTimerService {
        RestTimerService(
            notifications: notifications,
            haptics: haptics,
            now: { clock.now() }
        )
    }

    @Test
    func startSetsStateAndSchedulesNotification() async throws {
        let notifications = MockNotificationScheduling()
        let service = makeService(notifications: notifications)

        service.start(duration: 90)
        await Task.yield()

        #expect(service.total == 90)
        #expect(service.remaining == 90)
        #expect(service.isRunning)
        #expect(!service.isPaused)
        let call = try #require(notifications.scheduledRequests.first)
        #expect(call.seconds == 90)
    }

    @Test
    func startZeroDurationIsNoop() {
        let service = makeService()

        service.start(duration: 0)

        #expect(!service.isRunning)
        #expect(service.total == 0)
    }

    @Test
    func adjustPositiveExtendsRemaining() {
        let clock = Clock()
        let service = makeService(clock: clock)
        service.start(duration: 60)
        clock.advance(by: 20)

        service.adjust(by: 15)

        #expect(service.remaining > 50)
    }

    @Test
    func adjustNegativeReducesRemaining() {
        let clock = Clock()
        let service = makeService(clock: clock)
        service.start(duration: 60)
        clock.advance(by: 10)

        service.adjust(by: -15)

        #expect(service.remaining < 36)
    }

    @Test
    func skipFiresHapticAndStops() {
        let haptics = MockHapticsService()
        let service = makeService(haptics: haptics)
        service.start(duration: 60)

        service.skip()

        #expect(!service.isRunning)
        #expect(haptics.playedKinds == [.restDone])
    }

    @Test
    func skipCancelsScheduledNotification() async {
        let notifications = MockNotificationScheduling()
        let service = makeService(notifications: notifications)
        service.start(duration: 60)

        service.skip()
        await Task.yield()

        #expect(notifications.cancelCallCount >= 1)
    }

    @Test
    func pauseStopsCountdownKeepsRemaining() {
        let clock = Clock()
        let service = makeService(clock: clock)
        service.start(duration: 60)
        clock.advance(by: 10)
        service.adjust(by: 0)

        service.pause()

        #expect(service.isPaused)
        #expect(service.isRunning)
        let remBeforePause = service.remaining
        clock.advance(by: 20)
        #expect(service.remaining == remBeforePause)
    }

    @Test
    func resumeAfterPauseRestoresCountdown() {
        let clock = Clock()
        let service = makeService(clock: clock)
        service.start(duration: 90)
        service.pause()
        let remAtPause = service.remaining

        service.resume()

        #expect(!service.isPaused)
        #expect(service.isRunning)
        #expect(service.remaining <= remAtPause)
    }

    @Test
    func progressIsZeroWhenNotStarted() {
        let service = makeService()
        #expect(service.progress == 0)
    }

    @Test
    func progressIncreasesOverTime() {
        let clock = Clock()
        let service = makeService(clock: clock)
        service.start(duration: 100)
        clock.advance(by: 50)
        service.adjust(by: 0)

        #expect(service.progress > 0)
    }
}
