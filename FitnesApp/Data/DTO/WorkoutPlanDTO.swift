import Foundation

struct WorkoutPlanDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let targetMuscleGroups: [String]
    let planExercises: [PlanExerciseDTO]
}
