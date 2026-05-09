import Foundation
import SwiftData

@Model
final class PersonalRecord {
  @Attribute(.unique) var id: UUID
  var exercise: Exercise
  var date: Date
  var weight: Double
  var reps: Int
  var tonnage: Double

  init(
    id: UUID = UUID(),
    exercise: Exercise,
    date: Date,
    weight: Double,
    reps: Int
  ) {
    self.id = id
    self.exercise = exercise
    self.date = date
    self.weight = weight
    self.reps = reps
    self.tonnage = weight * Double(reps)
  }
}
