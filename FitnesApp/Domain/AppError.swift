import Foundation

enum AppError: Error, Sendable, Equatable {
    case sessionAlreadyActive(id: UUID)
    case sessionNotFound(id: UUID)
    case exerciseNotFound(id: UUID)
    case invalidSetInput
    case persistence(String)
    case notificationsDenied
}
