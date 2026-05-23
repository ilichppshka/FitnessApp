import Foundation
import SwiftData

extension ModelContainer {
    static let appSchema = Schema([
        MuscleGroup.self,
        Exercise.self,
        ExerciseExecutionStep.self,
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
        do {
            return try ModelContainer(
                for: appSchema,
                migrationPlan: AppMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            // Schema changed — wipe incompatible store and reseed fresh
            let supportDir = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first
            if let dir = supportDir {
                let storeURL = dir.appending(path: "FitnesApp.store")
                try? FileManager.default.removeItem(at: storeURL)
                try? FileManager.default.removeItem(at: dir.appending(path: "FitnesApp.store-shm"))
                try? FileManager.default.removeItem(at: dir.appending(path: "FitnesApp.store-wal"))
            }
            return try ModelContainer(for: appSchema, configurations: [config])
        }
    }

    static func makePreview() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: appSchema, configurations: [config])
    }
}
