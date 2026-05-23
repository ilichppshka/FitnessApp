import Foundation

extension WorkoutSet {
    func toDTO() -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: id,
            exerciseID: exercise.id,
            exerciseName: NSLocalizedString("exercise.\(exercise.slug).name", comment: exercise.slug),
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
            exerciseName: NSLocalizedString("exercise.\(exercise.slug).name", comment: exercise.slug),
            date: date,
            weight: weight,
            reps: reps,
            tonnage: tonnage
        )
    }
}

extension MuscleGroup {
    func toDTO() -> MuscleGroupDTO {
        MuscleGroupDTO(id: id, slug: slug)
    }
}

extension Exercise {
    func toDTO() -> ExerciseDTO {
        ExerciseDTO(
            id: id,
            slug: slug,
            equipment: equipment,
            difficulty: difficulty,
            primaryMuscleGroupSlugs: primaryMuscleGroups.map(\.slug),
            secondaryMuscleGroupSlugs: secondaryMuscleGroups.map(\.slug),
            animationAssetName: animationAssetName
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
