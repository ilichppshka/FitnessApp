@testable import FitnesApp
import Foundation
import SwiftData

@MainActor
enum InMemoryContainer {
    static func make() throws -> ModelContainer {
        try ModelContainer.makePreview()
    }
}
