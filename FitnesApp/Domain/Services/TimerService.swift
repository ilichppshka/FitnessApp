import Foundation
import Observation

@MainActor
@Observable
final class TimerService {
    private(set) var workoutElapsed: TimeInterval = 0
    private(set) var sessionStartedAt: Date?

    private var workoutTask: Task<Void, Never>?
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

    func stop() {
        workoutTask?.cancel()
        workoutTask = nil
        workoutElapsed = 0
        sessionStartedAt = nil
    }
}
