import Foundation
import SwiftData

enum DataSeeder {
    static func seedIfNeeded(_ context: ModelContext) throws {
        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        guard count == 0 else { return }
        let groups = MuscleGroupSeed.all.map { MuscleGroup(name: $0) }
        groups.forEach(context.insert)
        let exercises = ExerciseSeed.makeAll(groups: groups)
        exercises.forEach(context.insert)
        try context.save()
    }
}
