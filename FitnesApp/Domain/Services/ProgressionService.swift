import Foundation

@MainActor
final class ProgressionService: ProgressionServicing {
    private let sessions: SessionRepository
    private let exercises: ExerciseRepository

    init(sessions: SessionRepository, exercises: ExerciseRepository) {
        self.sessions = sessions
        self.exercises = exercises
    }

    func suggestion(
        exerciseID: UUID,
        plan: PlanExerciseDTO?
    ) async throws -> ProgressionSuggestion {
        let last = try await sessions.lastSet(exerciseID: exerciseID)

        let planTargetRepMax = plan?.targetRepMax ?? 12
        let planTargetWeight = plan?.planSets.first?.targetWeight ?? 0
        let planTargetReps = plan?.planSets.first?.targetReps ?? 8

        guard let last else {
            return ProgressionSuggestion(
                suggestedWeight: planTargetWeight,
                suggestedReps: planTargetReps,
                deltaVsLast: 0,
                lastSet: nil
            )
        }

        let exercise = try await exercises.find(id: exerciseID)
        let increment = weightIncrement(for: exercise)
        let reachedTop = last.reps >= planTargetRepMax

        let suggestedWeight: Double
        let suggestedReps: Int

        if reachedTop {
            suggestedWeight = last.weight + increment
            suggestedReps = max(1, planTargetReps - 2)
        } else {
            suggestedWeight = last.weight
            suggestedReps = min(planTargetRepMax, last.reps + 1)
        }

        return ProgressionSuggestion(
            suggestedWeight: suggestedWeight,
            suggestedReps: suggestedReps,
            deltaVsLast: suggestedWeight - last.weight,
            lastSet: last
        )
    }

    private func weightIncrement(for exercise: Exercise?) -> Double {
        switch exercise?.equipment {
        case .barbell: return 2.5
        case .dumbbell, .kettlebell: return 2
        default: return 1
        }
    }
}
