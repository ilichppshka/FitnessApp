import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {

    private(set) var userName: String = ""
    private(set) var weekDates: [Date] = []
    private(set) var today: Date
    var selectedDate: Date
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    let sessionsCompleted: Int = 3
    let sessionsGoal: Int = 5
    let totalVolume: String = "18,420"
    let volumeUnit: String = "kg"
    let weekNumber: Int = 3
    let mockExercises: Int = 6
    let mockMinutes: Int = 45
    let mockSets: Int = 22
    let mockMuscles: [String] = ["Lats", "Rhomboids", "Rear Delts", "Biceps"]
    let mockPRWeight: String = "142.5"
    let mockPRUnit: String = "kg"
    let mockPRExercise: String = "Deadlift"
    let mockPRTimeAgo: String = "2 days ago"

    var headerDateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: today).uppercased()
        formatter.dateFormat = "MMM d"
        let datePart = formatter.string(from: today).uppercased()
        return "\(dayName) · \(datePart)"
    }

    var greeting: String {
        userName.isEmpty
            ? String(localized: "dashboard.greeting.fallback")
            : String(localized: "dashboard.greeting \(userName)")
    }

    var weekRangeLabel: String {
        guard let first = weekDates.first, let last = weekDates.last else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first).uppercased()) – \(formatter.string(from: last).uppercased())"
    }

    private let userRepository: any UserRepository
    private let calendar: Calendar
    private let now: () -> Date

    init(
        userRepository: any UserRepository,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { Date() }
    ) {
        self.userRepository = userRepository
        self.calendar = calendar
        self.now = now
        let current = now()
        self.today = current
        self.selectedDate = current
    }

    func loadInitial() async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await userRepository.current()
            userName = profile.name
            weekDates = buildWeekDates()
            isLoading = false
        } catch {
            errorMessage = String(localized: "dashboard.error.generic")
            isLoading = false
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    private func buildWeekDates() -> [Date] {
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
}
