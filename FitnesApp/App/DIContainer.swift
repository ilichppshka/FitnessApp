import Foundation
import SwiftData

@Observable
final class DIContainer {
    let workoutService: any WorkoutServicing
    let analyticsService: any AnalyticsServicing
    let exerciseRepository: any ExerciseRepository
    let sessionRepository: any SessionRepository
    let workoutRepository: any WorkoutRepository
    let userRepository: any UserRepository

    init(modelContext: ModelContext) {
        let exerciseRepo = SwiftDataExerciseRepository(context: modelContext)
        let sessionRepo = SwiftDataSessionRepository(context: modelContext)
        let planRepo = SwiftDataWorkoutRepository(context: modelContext)
        let userRepo = SwiftDataUserRepository(context: modelContext)

        self.exerciseRepository = exerciseRepo
        self.sessionRepository = sessionRepo
        self.workoutRepository = planRepo
        self.userRepository = userRepo
        self.workoutService = WorkoutService(sessions: sessionRepo, exercises: exerciseRepo)
        self.analyticsService = AnalyticsService(sessions: sessionRepo, exercises: exerciseRepo)
    }
}
