@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct TimerServiceTests {
    private final class Clock {
        var current: Date
        init(_ date: Date) { self.current = date }
        func now() -> Date { current }
        func advance(by seconds: TimeInterval) { current = current.addingTimeInterval(seconds) }
    }

    private func makeService(_ clock: Clock) -> TimerService {
        TimerService(now: { clock.now() })
    }

    @Test
    func startWorkoutSetsImmediateElapsed() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)
        let startedAt = clock.current.addingTimeInterval(-30)

        service.startWorkout(startedAt: startedAt)

        #expect(service.workoutElapsed == 30)
        #expect(service.sessionStartedAt == startedAt)
        service.stop()
    }

    @Test
    func stopResetsState() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)
        service.startWorkout(startedAt: clock.current.addingTimeInterval(-100))

        service.stop()

        #expect(service.workoutElapsed == 0)
        #expect(service.sessionStartedAt == nil)
    }
}
