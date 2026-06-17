import Foundation

enum WorkoutError: Error, Sendable, Equatable {
    case sessionAlreadyActive(id: UUID)
    case sessionNotFound(id: UUID)
    case noActiveSession
    case invalidSetInput
}

enum DataError: Error, Sendable, Equatable {
    case exerciseNotFound(id: UUID)
    case persistence(String)
    case notificationsDenied
}
