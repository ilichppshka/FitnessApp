import Foundation
import SwiftData

@Model
final class MuscleGroup {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var slug: String

    init(id: UUID = UUID(), slug: String) {
        self.id = id
        self.slug = slug
    }
}
