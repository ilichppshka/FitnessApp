import Foundation

struct UserProfileDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let bodyWeight: Double
    let heightCm: Double?
    let weightUnit: WeightUnit
    let selectedMascotId: String
    let defaultRestDuration: TimeInterval
    let autoStartRestTimer: Bool
    let restSoundEnabled: Bool
    let restHapticEnabled: Bool
    let createdAt: Date
}
