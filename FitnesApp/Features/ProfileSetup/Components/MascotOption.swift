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
        case .athlete: "profileSetup.mascot.athlete"
        case .runner:  "profileSetup.mascot.runner"
        case .yogi:    "profileSetup.mascot.yogi"
        }
    }
}
