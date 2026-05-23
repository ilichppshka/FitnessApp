import SwiftUI

enum MascotOption: String, CaseIterable, Identifiable {
    case athlete
    case runner
    case yogi

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .athlete: "figure.strengthtraining.traditional"
        case .runner:  "figure.run"
        case .yogi:    "figure.mind.and.body"
        }
    }

    var titleResource: LocalizedStringResource {
        switch self {
        case .athlete: LocalizedStringResource("profileSetup.mascot.athlete", table: "Onboarding")
        case .runner:  LocalizedStringResource("profileSetup.mascot.runner", table: "Onboarding")
        case .yogi:    LocalizedStringResource("profileSetup.mascot.yogi", table: "Onboarding")
        }
    }
}
