import Foundation
import Observation

@MainActor
@Observable
final class TimerService {
    private(set) var workoutElapsed: TimeInterval = 0
    private(set) var restRemaining: TimeInterval = 0
    private(set) var isRestRunning: Bool = false

    private var workoutTask: Task<Void, Never>?
    private var restTask: Task<Void, Never>?
    private(set) var sessionStartedAt: Date?
    private(set) var restEndsAt: Date?

    private let now: @MainActor () -> Date

    init(now: @escaping @MainActor () -> Date = { .now }) {
        self.now = now
    }

    func startWorkout(startedAt: Date) {
        sessionStartedAt = startedAt
        workoutElapsed = max(0, now().timeIntervalSince(startedAt))
        workoutTask?.cancel()
        workoutTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let started = self.sessionStartedAt else { return }
                self.workoutElapsed = max(0, self.now().timeIntervalSince(started))
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func startRest(duration: TimeInterval) {
        let endsAt = now().addingTimeInterval(duration)
        restEndsAt = endsAt
        restRemaining = max(0, duration)
        isRestRunning = duration > 0
        restTask?.cancel()
        guard isRestRunning else { return }
        restTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let ends = self.restEndsAt else { return }
                let remaining = ends.timeIntervalSince(self.now())
                if remaining <= 0 {
                    self.restRemaining = 0
                    self.isRestRunning = false
                    return
                }
                self.restRemaining = remaining
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    func extendRest(by seconds: TimeInterval) {
        guard let ends = restEndsAt else { return }
        let updated = ends.addingTimeInterval(seconds)
        restEndsAt = updated
        restRemaining = max(0, updated.timeIntervalSince(now()))
        isRestRunning = restRemaining > 0
    }

    func stopAll() {
        workoutTask?.cancel()
        restTask?.cancel()
        workoutTask = nil
        restTask = nil
        isRestRunning = false
        restRemaining = 0
        workoutElapsed = 0
        sessionStartedAt = nil
        restEndsAt = nil
    }
}
