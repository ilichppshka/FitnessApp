import Foundation
import Observation

@MainActor
@Observable
final class ExerciseDetailViewModel {
    private let repository: any ExerciseRepository

    private(set) var exercise: Exercise?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(repository: any ExerciseRepository) {
        self.repository = repository
    }

    func load(id: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            exercise = try await repository.find(id: id)
            if exercise == nil {
                errorMessage = String(localized: "library.detail.error.notFound")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleFavorite() async {
        guard let exercise else { return }
        do {
            try await repository.setFavorite(exercise.id, !exercise.isFavorite)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
