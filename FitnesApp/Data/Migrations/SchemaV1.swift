import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            MuscleGroup.self,
            Exercise.self,
            PersonalRecord.self,
            WorkoutPlan.self,
            PlanExercise.self,
            WorkoutSession.self,
            WorkoutSet.self,
            UserProfile.self
        ]
    }
}
