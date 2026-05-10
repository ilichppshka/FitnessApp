import Foundation

enum TonnageCalculator {
    static func compute(weight: Double, reps: Int) -> Double {
        weight * Double(reps)
    }
}
