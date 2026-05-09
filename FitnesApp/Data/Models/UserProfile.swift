import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var bodyWeight: Double
    var selectedMascotId: String
    var restSoundEnabled: Bool
    var restHapticEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        bodyWeight: Double,
        selectedMascotId: String,
        restSoundEnabled: Bool = true,
        restHapticEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.bodyWeight = bodyWeight
        self.selectedMascotId = selectedMascotId
        self.restSoundEnabled = restSoundEnabled
        self.restHapticEnabled = restHapticEnabled
    }
}
