import Foundation

extension WorkoutSet {
    func toDTO() -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: id,
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            setNumber: setNumber,
            weight: weight,
            reps: reps,
            tonnage: tonnage,
            loggedAt: loggedAt
        )
    }
}

extension PersonalRecord {
    func toDTO() -> PersonalRecordDTO {
        PersonalRecordDTO(
            id: id,
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            date: date,
            weight: weight,
            reps: reps,
            tonnage: tonnage
        )
    }
}

extension MuscleGroup {
    func toDTO() -> MuscleGroupDTO {
        MuscleGroupDTO(id: id, name: name)
    }
}

extension Exercise {
    func toDTO() -> ExerciseDTO {
        ExerciseDTO(
            id: id,
            name: name,
            descriptionStart: descriptionStart,
            descriptionExecution: descriptionExecution,
            descriptionErrors: descriptionErrors,
            animationAssetName: animationAssetName,
            muscleGroups: muscleGroups
                .map(\.name)
                .sorted()
        )
    }
}

extension WorkoutSession {
    func toDTO() -> WorkoutSessionDTO {
        WorkoutSessionDTO(
            id: id,
            planName: plan?.name,
            startedAt: startedAt,
            finishedAt: finishedAt,
            totalTonnage: totalTonnage,
            sets: sets
                .sorted { $0.loggedAt < $1.loggedAt }
                .map { $0.toDTO() }
        )
    }
}
