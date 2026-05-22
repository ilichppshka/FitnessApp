import Foundation
import SwiftUI

@Observable
final class AppRouter {
    enum Tab: Hashable, CaseIterable {
        case dashboard, library, progress, settings
    }

    var selectedTab: Tab = .dashboard

    var dashboardPath = NavigationPath()
    var libraryPath = NavigationPath()
    var progressPath = NavigationPath()
    var settingsPath = NavigationPath()

    var presentedActiveSessionID: UUID?
    var presentedExerciseDetailID: UUID?
    var presentedBuilderPlanID: UUID?

    func presentActiveWorkout(sessionID: UUID) {
        presentedActiveSessionID = sessionID
    }

    func dismissActiveWorkout() {
        presentedActiveSessionID = nil
    }
}
