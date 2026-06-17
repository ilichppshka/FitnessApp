@testable import FitnesApp
import Foundation
import Testing

@MainActor
struct HapticsServiceTests {
    @Test
    func playSetLoggedDoesNotCrash() {
        let user = MockUserRepository()
        let service = UIKitHapticsService(user: user)
        service.play(.setLogged)
    }

    @Test
    func playPersonalRecordDoesNotCrash() {
        let user = MockUserRepository()
        let service = UIKitHapticsService(user: user)
        service.play(.personalRecord)
    }

    @Test
    func playRestDoneDoesNotCrashWhenEnabled() {
        let user = MockUserRepository()
        user.currentResult = UserProfile(name: "Test", bodyWeight: 75, restHapticEnabled: true)
        let service = UIKitHapticsService(user: user)
        service.play(.restDone)
    }

    @Test
    func playRestDoneDoesNotCrashWhenDisabled() {
        let user = MockUserRepository()
        user.currentResult = UserProfile(name: "Test", bodyWeight: 75, restHapticEnabled: false)
        let service = UIKitHapticsService(user: user)
        service.play(.restDone)
    }
}
