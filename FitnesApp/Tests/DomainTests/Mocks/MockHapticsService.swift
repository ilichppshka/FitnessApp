@testable import FitnesApp
import Foundation

@MainActor
final class MockHapticsService: HapticsService {
    private(set) var playedKinds: [HapticKind] = []

    func play(_ kind: HapticKind) {
        playedKinds.append(kind)
    }
}
