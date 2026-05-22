import Foundation
import Observation

@Observable
final class OnboardingFlowViewModel {
    enum Step: Int, CaseIterable, Hashable {
        case welcome, log, analyze
    }

    var currentStep: Step = .welcome
    var showsProfileSetup: Bool = false

    func next() {
        switch currentStep {
        case .welcome: currentStep = .log
        case .log: currentStep = .analyze
        case .analyze: showsProfileSetup = true
        }
    }

    func skip() {
        showsProfileSetup = true
    }
}
