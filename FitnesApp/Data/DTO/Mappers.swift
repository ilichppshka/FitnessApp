import Foundation

extension WorkoutSet {
    func toDTO() -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: id,
            exerciseID: exercise?.id,
            exerciseName: exercise.map { ex in
                NSLocalizedString("exercise.\(ex.slug).name", comment: ex.slug)
            } ?? "",
            setNumber: setNumber,
            weight: weight,
            reps: reps,
            tonnage: tonnage,
            isPersonalRecord: isPersonalRecord,
            loggedAt: loggedAt
        )
    }
}

extension PersonalRecord {
    func toDTO() -> PersonalRecordDTO {
        PersonalRecordDTO(
            id: id,
            exerciseID: exercise?.id,
            exerciseName: exercise.map { ex in
                NSLocalizedString("exercise.\(ex.slug).name", comment: ex.slug)
            } ?? "",
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
            primaryMuscleGroupSlugs: primaryMuscles.map(\.slug),
            secondaryMuscleGroupSlugs: secondaryMuscles.map(\.slug),
            animationAssetName: animationAssetName
        )
    }
}

extension PlanSet {
    func toDTO() -> PlanSetDTO {
        PlanSetDTO(
            id: id,
            order: order,
            targetWeight: targetWeight,
            targetReps: targetReps
        )
    }
}

extension PlanExercise {
    func toDTO() -> PlanExerciseDTO {
        PlanExerciseDTO(
            id: id,
            exerciseID: exercise?.id,
            exerciseName: exercise.map { ex in
                NSLocalizedString("exercise.\(ex.slug).name", comment: ex.slug)
            } ?? "",
            order: order,
            targetSets: targetSets,
            targetRepMin: targetRepMin,
            targetRepMax: targetRepMax,
            restDuration: restDuration,
            planSets: planSets.sorted { $0.order < $1.order }.map { $0.toDTO() }
        )
    }
}

extension WorkoutPlan {
    func toDTO() -> WorkoutPlanDTO {
        WorkoutPlanDTO(
            id: id,
            name: name,
            category: category,
            isDraft: isDraft,
            scheduledWeekdays: scheduledWeekdays,
            targetMuscleGroups: targetMuscleGroups.map(\.slug),
            planExercises: planExercises.sorted { $0.order < $1.order }.map { $0.toDTO() }
        )
    }
}

extension WorkoutSession {
    func toDTO() -> WorkoutSessionDTO {
        WorkoutSessionDTO(
            id: id,
            title: title,
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

extension UserProfile {
    func toDTO() -> UserProfileDTO {
        UserProfileDTO(
            id: id,
            name: name,
            bodyWeight: bodyWeight,
            heightCm: heightCm,
            weightUnit: weightUnit,
            selectedMascotId: selectedMascotId,
            defaultRestDuration: defaultRestDuration,
            autoStartRestTimer: autoStartRestTimer,
            restSoundEnabled: restSoundEnabled,
            restHapticEnabled: restHapticEnabled,
            createdAt: createdAt
        )
    }
}
