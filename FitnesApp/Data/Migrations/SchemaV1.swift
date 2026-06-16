import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            MuscleGroup.self,
            ExerciseMuscle.self,
            Exercise.self,
            ExerciseExecutionStep.self,
            PersonalRecord.self,
            WorkoutPlan.self,
            PlanExercise.self,
            PlanSet.self,
            WorkoutSession.self,
            WorkoutSet.self,
            UserProfile.self
        ]
    }
}
