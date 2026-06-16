import Foundation

enum ExerciseSeed {
    static func makeAll(groups: [MuscleGroup]) -> (exercises: [Exercise], muscleLinks: [ExerciseMuscle]) {
        let bySlug = Dictionary(uniqueKeysWithValues: groups.map { ($0.slug, $0) })
        var allLinks: [ExerciseMuscle] = []
        let exercises = seeds.map { seed -> Exercise in
            let exercise = Exercise(
                slug: seed.slug,
                equipment: seed.equipment,
                difficulty: seed.difficulty
            )
            exercise.mistakeKeys = seed.mistakeKeys
            exercise.executionSteps = seed.stepKeys.enumerated().map { index, key in
                ExerciseExecutionStep(exercise: exercise, order: index + 1, key: key)
            }
            let primaryLinks = seed.primarySlugs.compactMap { bySlug[$0] }.map { group in
                ExerciseMuscle(role: .primary, exercise: exercise, muscleGroup: group)
            }
            let secondaryLinks = seed.secondarySlugs.compactMap { bySlug[$0] }.map { group in
                ExerciseMuscle(role: .secondary, exercise: exercise, muscleGroup: group)
            }
            let links = primaryLinks + secondaryLinks
            exercise.muscleLinks = links
            allLinks.append(contentsOf: links)
            return exercise
        }
        return (exercises, allLinks)
    }

    private struct Seed {
        let slug: String
        let equipment: ExerciseEquipment
        let difficulty: ExerciseDifficulty
        let primarySlugs: [String]
        let secondarySlugs: [String]
        let stepKeys: [String]
        let mistakeKeys: [String]
    }

    private static let seeds: [Seed] = [
        // MARK: Chest
        Seed(
            slug: "bench_press",
            equipment: .barbell,
            difficulty: .intermediate,
            primarySlugs: ["chest"],
            secondarySlugs: ["triceps", "shoulders"],
            stepKeys: ["setup", "descent", "press"],
            mistakeKeys: ["hip_drive", "flared_elbows", "bouncing"]
        ),
        Seed(
            slug: "dips",
            equipment: .bodyweight,
            difficulty: .intermediate,
            primarySlugs: ["chest", "triceps"],
            secondarySlugs: [],
            stepKeys: ["setup", "descent", "press"],
            mistakeKeys: ["too_deep", "flared_elbows", "swinging"]
        ),
        // MARK: Back
        Seed(
            slug: "pull_up",
            equipment: .bodyweight,
            difficulty: .intermediate,
            primarySlugs: ["back"],
            secondarySlugs: ["biceps"],
            stepKeys: ["grip", "pull", "descent"],
            mistakeKeys: ["swinging", "partial_range", "shoulder_shrug"]
        ),
        Seed(
            slug: "deadlift",
            equipment: .barbell,
            difficulty: .advanced,
            primarySlugs: ["back"],
            secondarySlugs: ["hamstrings", "glutes"],
            stepKeys: ["setup", "drive", "lockout"],
            mistakeKeys: ["rounded_back", "bar_away", "hyperextension"]
        ),
        // MARK: Shoulders
        Seed(
            slug: "overhead_press",
            equipment: .barbell,
            difficulty: .intermediate,
            primarySlugs: ["shoulders"],
            secondarySlugs: ["triceps"],
            stepKeys: ["setup", "press", "return"],
            mistakeKeys: ["lower_back_arch", "behind_head", "leg_drive"]
        ),
        Seed(
            slug: "lateral_raise",
            equipment: .dumbbell,
            difficulty: .beginner,
            primarySlugs: ["shoulders"],
            secondarySlugs: [],
            stepKeys: ["setup", "raise", "lower"],
            mistakeKeys: ["above_shoulders", "body_sway", "locked_elbows"]
        ),
        // MARK: Biceps
        Seed(
            slug: "barbell_curl",
            equipment: .barbell,
            difficulty: .beginner,
            primarySlugs: ["biceps"],
            secondarySlugs: [],
            stepKeys: ["setup", "curl", "return"],
            mistakeKeys: ["body_swing", "elbow_forward", "partial_range"]
        ),
        // MARK: Triceps
        Seed(
            slug: "cable_pushdown",
            equipment: .cable,
            difficulty: .beginner,
            primarySlugs: ["triceps"],
            secondarySlugs: [],
            stepKeys: ["setup", "push", "return"],
            mistakeKeys: ["elbow_flare", "forward_lean", "jerking"]
        ),
        // MARK: Quads
        Seed(
            slug: "squat",
            equipment: .barbell,
            difficulty: .advanced,
            primarySlugs: ["quads"],
            secondarySlugs: ["glutes", "hamstrings"],
            stepKeys: ["setup", "descent", "ascent"],
            mistakeKeys: ["knee_cave", "rounded_back", "heel_raise"]
        ),
        Seed(
            slug: "leg_press",
            equipment: .machine,
            difficulty: .beginner,
            primarySlugs: ["quads"],
            secondarySlugs: ["glutes"],
            stepKeys: ["setup", "descent", "press"],
            mistakeKeys: ["hip_lift", "knee_lockout", "short_range"]
        ),
        // MARK: Hamstrings
        Seed(
            slug: "romanian_deadlift",
            equipment: .barbell,
            difficulty: .intermediate,
            primarySlugs: ["hamstrings"],
            secondarySlugs: ["glutes", "back"],
            stepKeys: ["setup", "hinge", "return"],
            mistakeKeys: ["rounded_back", "knee_bend", "bar_away"]
        ),
        // MARK: Glutes
        Seed(
            slug: "hip_thrust",
            equipment: .barbell,
            difficulty: .intermediate,
            primarySlugs: ["glutes"],
            secondarySlugs: ["hamstrings"],
            stepKeys: ["setup", "drive", "return"],
            mistakeKeys: ["lumbar_hyperextension", "incomplete_extension", "bar_pressure"]
        ),
        // MARK: Core
        Seed(
            slug: "crunch",
            equipment: .bodyweight,
            difficulty: .beginner,
            primarySlugs: ["core"],
            secondarySlugs: [],
            stepKeys: ["setup", "crunch", "return"],
            mistakeKeys: ["neck_pull", "full_situp", "momentum"]
        ),
        // MARK: Calves
        Seed(
            slug: "standing_calf_raise",
            equipment: .machine,
            difficulty: .beginner,
            primarySlugs: ["calves"],
            secondarySlugs: [],
            stepKeys: ["setup", "raise", "lower"],
            mistakeKeys: ["short_range", "jerking", "knee_bend"]
        )
    ]
}
