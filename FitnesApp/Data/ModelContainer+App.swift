import Foundation
import SwiftData

extension ModelContainer {
    static let appSchema = Schema([
        MuscleGroup.self,
        Exercise.self,
        PersonalRecord.self,
        WorkoutPlan.self,
        PlanExercise.self,
        WorkoutSession.self,
        WorkoutSet.self,
        UserProfile.self
    ])

    static func makeProduction() throws -> ModelContainer {
        let config = ModelConfiguration(
            "FitnesApp",
            schema: appSchema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        return try ModelContainer(
            for: appSchema,
            migrationPlan: AppMigrationPlan.self,
            configurations: [config]
        )
    }

    static func makePreview() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: appSchema, configurations: [config])
    }
}
