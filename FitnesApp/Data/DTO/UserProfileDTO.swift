import Foundation

struct UserProfileDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let bodyWeight: Double
    let selectedMascotId: String
    let restSoundEnabled: Bool
    let restHapticEnabled: Bool
}
