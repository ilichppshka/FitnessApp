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
        service.stopAll()
    }

    @Test
    func startRestInitializesRemainingAndRunning() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)

        service.startRest(duration: 90)

        #expect(service.restRemaining == 90)
        #expect(service.isRestRunning)
        #expect(service.restEndsAt == clock.current.addingTimeInterval(90))
        service.stopAll()
    }

    @Test
    func startRestZeroDurationDoesNotRun() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)

        service.startRest(duration: 0)

        #expect(service.restRemaining == 0)
        #expect(service.isRestRunning == false)
        service.stopAll()
    }

    @Test
    func extendRestPushesEndDateAndRecomputesRemaining() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)
        service.startRest(duration: 60)

        clock.advance(by: 30)
        service.extendRest(by: 15)

        #expect(service.restRemaining == 45)
        #expect(service.isRestRunning)
        service.stopAll()
    }

    @Test
    func extendRestWithoutActiveRestIsNoop() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)

        service.extendRest(by: 30)

        #expect(service.restRemaining == 0)
        #expect(service.isRestRunning == false)
        #expect(service.restEndsAt == nil)
    }

    @Test
    func stopAllResetsState() async throws {
        let clock = Clock(Date(timeIntervalSince1970: 1_000_000))
        let service = makeService(clock)
        service.startWorkout(startedAt: clock.current.addingTimeInterval(-100))
        service.startRest(duration: 60)

        service.stopAll()

        #expect(service.isRestRunning == false)
        #expect(service.restRemaining == 0)
        #expect(service.workoutElapsed == 0)
        #expect(service.sessionStartedAt == nil)
        #expect(service.restEndsAt == nil)
    }
}
