import Foundation

struct WorkoutPlanDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String?
    let isDraft: Bool
    let scheduledWeekdays: [Int]
    let targetMuscleGroups: [String]
    let planExercises: [PlanExerciseDTO]
}
