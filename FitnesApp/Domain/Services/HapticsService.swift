import UIKit

enum HapticKind {
    case setLogged
    case restDone
    case personalRecord
}

@MainActor
protocol HapticsService {
    func play(_ kind: HapticKind)
}

@MainActor
final class UIKitHapticsService: HapticsService {
    private let user: UserRepository

    init(user: UserRepository) {
        self.user = user
    }

    func play(_ kind: HapticKind) {
        Task {
            guard await hapticsEnabled(for: kind) else { return }
            switch kind {
            case .setLogged:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .restDone:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .personalRecord:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    private func hapticsEnabled(for kind: HapticKind) async -> Bool {
        guard let profile = try? await user.current() else { return true }
        switch kind {
        case .restDone: return profile.restHapticEnabled
        case .setLogged, .personalRecord: return true
        }
    }
}
