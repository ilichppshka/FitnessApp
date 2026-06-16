import Foundation
import SwiftData

enum DataSeeder {
    static func seedIfNeeded(_ context: ModelContext) throws {
        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        guard count == 0 else { return }
        let groups = MuscleGroupSeed.all.enumerated().map { index, slug in
            MuscleGroup(slug: slug, displayOrder: index)
        }
        groups.forEach(context.insert)
        let (exercises, muscleLinks) = ExerciseSeed.makeAll(groups: groups)
        for exercise in exercises {
            context.insert(exercise)
            exercise.executionSteps.forEach(context.insert)
        }
        muscleLinks.forEach(context.insert)
        try context.save()
    }
}
