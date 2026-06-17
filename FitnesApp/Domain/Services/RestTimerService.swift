import Foundation
import Observation

@MainActor
@Observable
final class RestTimerService {
    private(set) var total: TimeInterval = 0
    private(set) var remaining: TimeInterval = 0
    private(set) var isRunning = false
    private(set) var isPaused = false

    var progress: Double { total > 0 ? 1.0 - remaining / total : 0 }

    private var restEndsAt: Date?
    private var pausedRemaining: TimeInterval = 0
    private var countdownTask: Task<Void, Never>?

    private let notifications: NotificationScheduling
    private let haptics: HapticsService
    private let now: @MainActor () -> Date

    init(
        notifications: NotificationScheduling,
        haptics: HapticsService,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        self.notifications = notifications
        self.haptics = haptics
        self.now = now
    }

    func start(duration: TimeInterval) {
        guard duration > 0 else { return }
        stop()
        total = duration
        remaining = duration
        restEndsAt = now().addingTimeInterval(duration)
        isRunning = true
        isPaused = false
        scheduleNotification(after: duration)
        startCountdown()
    }

    func adjust(by seconds: TimeInterval) {
        guard isRunning, !isPaused, let ends = restEndsAt else { return }
        let newEnds = ends.addingTimeInterval(seconds)
        restEndsAt = newEnds
        let newRemaining = max(0, newEnds.timeIntervalSince(now()))
        remaining = newRemaining
        total = max(total + seconds, remaining)
        cancelNotification()
        if newRemaining > 0 {
            scheduleNotification(after: newRemaining)
        } else {
            handleCompletion()
        }
    }

    func skip() {
        stop()
        haptics.play(.restDone)
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        pausedRemaining = remaining
        isPaused = true
        countdownTask?.cancel()
        countdownTask = nil
        cancelNotification()
    }

    func resume() {
        guard isRunning, isPaused else { return }
        isPaused = false
        let newEnds = now().addingTimeInterval(pausedRemaining)
        restEndsAt = newEnds
        remaining = pausedRemaining
        scheduleNotification(after: pausedRemaining)
        startCountdown()
    }

    // MARK: - Private

    private func stop() {
        countdownTask?.cancel()
        countdownTask = nil
        cancelNotification()
        total = 0
        remaining = 0
        isRunning = false
        isPaused = false
        restEndsAt = nil
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let ends = self.restEndsAt else { return }
                let rem = ends.timeIntervalSince(self.now())
                if rem <= 0 {
                    self.handleCompletion()
                    return
                }
                self.remaining = rem
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    private func handleCompletion() {
        countdownTask?.cancel()
        countdownTask = nil
        remaining = 0
        isRunning = false
        isPaused = false
        restEndsAt = nil
        haptics.play(.restDone)
    }

    private func scheduleNotification(after seconds: TimeInterval) {
        Task {
            try? await notifications.scheduleRestEnd(after: seconds, soundEnabled: true)
        }
    }

    private func cancelNotification() {
        Task {
            await notifications.cancelRestEnd()
        }
    }
}
