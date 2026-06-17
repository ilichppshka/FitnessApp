import Foundation

enum OneRepMaxCalculator {
    // Epley formula: weight × (1 + reps / 30)
    static func epley(weight: Double, reps: Int) -> Double {
        weight * (1.0 + Double(reps) / 30.0)
    }
}
