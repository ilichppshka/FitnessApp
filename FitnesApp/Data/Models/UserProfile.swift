import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var bodyWeight: Double
    var heightCm: Double?
    var weightUnit: WeightUnit
    var selectedMascotId: String
    var defaultRestDuration: TimeInterval
    var autoStartRestTimer: Bool
    var restSoundEnabled: Bool
    var restHapticEnabled: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        bodyWeight: Double,
        heightCm: Double? = nil,
        weightUnit: WeightUnit = .kg,
        selectedMascotId: String = "duck",
        defaultRestDuration: TimeInterval = 120,
        autoStartRestTimer: Bool = true,
        restSoundEnabled: Bool = true,
        restHapticEnabled: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.bodyWeight = bodyWeight
        self.heightCm = heightCm
        self.weightUnit = weightUnit
        self.selectedMascotId = selectedMascotId
        self.defaultRestDuration = defaultRestDuration
        self.autoStartRestTimer = autoStartRestTimer
        self.restSoundEnabled = restSoundEnabled
        self.restHapticEnabled = restHapticEnabled
        self.createdAt = createdAt
    }
}
