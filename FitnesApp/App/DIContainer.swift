import Foundation
import SwiftData

@Observable
@MainActor
final class AppServices {
    let workoutService: any WorkoutServicing
    let analyticsService: any AnalyticsServicing
    let progressionService: any ProgressionServicing
    let notificationService: any NotificationScheduling
    let hapticsService: any HapticsService
    let restTimerService: RestTimerService
    let timerService: TimerService
    let csvExporter: CSVExporter
    let exerciseRepository: any ExerciseRepository
    let sessionRepository: any SessionRepository
    let workoutRepository: any WorkoutRepository
    let userRepository: any UserRepository

    init(modelContext: ModelContext) {
        let exerciseRepo = SwiftDataExerciseRepository(context: modelContext)
        let sessionRepo = SwiftDataSessionRepository(context: modelContext)
        let planRepo = SwiftDataWorkoutRepository(context: modelContext)
        let userRepo = SwiftDataUserRepository(context: modelContext)
        let notifications = NotificationService()
        let haptics = UIKitHapticsService(user: userRepo)

        self.exerciseRepository = exerciseRepo
        self.sessionRepository = sessionRepo
        self.workoutRepository = planRepo
        self.userRepository = userRepo
        self.notificationService = notifications
        self.hapticsService = haptics
        self.restTimerService = RestTimerService(notifications: notifications, haptics: haptics)
        self.timerService = TimerService()
        self.csvExporter = CSVExporter()
        self.workoutService = WorkoutService(sessions: sessionRepo, exercises: exerciseRepo)
        self.progressionService = ProgressionService(sessions: sessionRepo, exercises: exerciseRepo)
        self.analyticsService = AnalyticsService(
            sessions: sessionRepo,
            exercises: exerciseRepo,
            plans: planRepo
        )
    }
}

// MARK: - Deprecated alias kept during call-site migration
typealias DIContainer = AppServices
