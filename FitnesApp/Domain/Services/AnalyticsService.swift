import Foundation

@MainActor
final class AnalyticsService: AnalyticsServicing {
    private let sessions: SessionRepository
    private let exercises: ExerciseRepository
    private let plans: WorkoutRepository
    private let now: @MainActor () -> Date

    init(
        sessions: SessionRepository,
        exercises: ExerciseRepository,
        plans: WorkoutRepository,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        self.sessions = sessions
        self.exercises = exercises
        self.plans = plans
        self.now = now
    }

    // MARK: - Progress

    func totalTonnage(range: DateRange) async throws -> Metric {
        let current = try await fetchTonnage(in: Calendar.range(for: range, now: now()))
        let previous = try await previousTonnage(range: range)
        return makeMetric(current: current, previous: previous)
    }

    func tonnageSeries(range: DateRange) async throws -> [TonnagePoint] {
        let dateRange = Calendar.range(for: range, now: now())
        let history = try await sessions.history(range: dateRange)
        let buckets = Dictionary(
            grouping: history,
            by: { Calendar.startOfDay($0.startedAt) }
        )
        return dateRange.allDays.map { day in
            let tonnage = buckets[day]?.reduce(0) { $0 + $1.totalTonnage } ?? 0
            return TonnagePoint(date: day, tonnage: tonnage)
        }
    }

    func sessionsCount(range: DateRange) async throws -> Metric {
        let dateRange = Calendar.range(for: range, now: now())
        let current = Double(try await sessions.history(range: dateRange).count)
        let previous: Double?
        if let prevRange = Calendar.previousRange(for: range, now: now()) {
            previous = Double(try await sessions.history(range: prevRange).count)
        } else {
            previous = nil
        }
        return makeMetric(current: current, previous: previous)
    }

    func totalTime(range: DateRange) async throws -> Metric {
        let dateRange = Calendar.range(for: range, now: now())
        let current = try await sessions.history(range: dateRange)
            .reduce(0.0) { sum, session in
                sum + (session.finishedAt.map { $0.timeIntervalSince(session.startedAt) } ?? 0)
            }
        let previous: Double?
        if let prevRange = Calendar.previousRange(for: range, now: now()) {
            previous = try await sessions.history(range: prevRange)
                .reduce(0.0) { sum, session in
                    sum + (session.finishedAt.map { $0.timeIntervalSince(session.startedAt) } ?? 0)
                }
        } else {
            previous = nil
        }
        return makeMetric(current: current, previous: previous)
    }

    func newPRsCount(range: DateRange) async throws -> Metric {
        let dateRange = Calendar.range(for: range, now: now())
        let history = try await sessions.history(range: dateRange)
        let current = Double(history.flatMap(\.sets).filter(\.isPersonalRecord).count)
        let previous: Double?
        if let prevRange = Calendar.previousRange(for: range, now: now()) {
            let prevHistory = try await sessions.history(range: prevRange)
            previous = Double(prevHistory.flatMap(\.sets).filter(\.isPersonalRecord).count)
        } else {
            previous = nil
        }
        return makeMetric(current: current, previous: previous)
    }

    func currentStreak() async throws -> Int {
        let history = try await sessions.history(range: Date.distantPast...now())
        guard !history.isEmpty else { return 0 }
        let calendar = Calendar.iso8601
        let sortedDates =
            history
            .compactMap(\.finishedAt)
            .map { calendar.startOfDay(for: $0) }
        let uniqueDays = Array(Set(sortedDates)).sorted(by: >)
        let todayStart = calendar.startOfDay(for: now())
        var streak = 0
        var expected = todayStart
        for day in uniqueDays {
            if day == expected {
                streak += 1
                expected = calendar.date(byAdding: .day, value: -1, to: expected) ?? expected
            } else if day < expected {
                break
            }
        }
        return streak
    }

    // MARK: - Exercise Detail

    func estimatedOneRepMax(exerciseID: UUID) async throws -> Double? {
        guard let best = try await exercises.bestPersonalRecord(exerciseID: exerciseID) else {
            return nil
        }
        return OneRepMaxCalculator.epley(weight: best.weight, reps: best.reps)
    }

    func attempts(exerciseID: UUID) async throws -> Int {
        let history = try await sessions.history(range: Date.distantPast...now())
        return history.flatMap(\.sets).filter { $0.exerciseID == exerciseID }.count
    }

    // MARK: - Dashboard

    func weekStates(weekOf date: Date) async throws -> [DayState] {
        let weekRange = Calendar.iso8601WeekRange(reference: date)
        let days = weekRange.allDays
        let history = try await sessions.history(range: weekRange)
        let doneDays = Set(
            history.compactMap(\.finishedAt).map { Calendar.startOfDay($0) }
        )
        let todayStart = Calendar.startOfDay(now())
        let allPlans = try await plans.plans(includeDrafts: false)

        return days.map { day in
            if doneDays.contains(day) { return .done }
            if day == todayStart { return .today }
            let dayWeekday = Calendar.iso8601.component(.weekday, from: day)
            let hasPlanned = allPlans.contains { $0.scheduledWeekdays.contains(dayWeekday) }
            return hasPlanned ? .planned : .rest
        }
    }

    func weeklyVolume() async throws -> Metric {
        let weekRange = Calendar.iso8601WeekRange(reference: now())
        let current = try await fetchTonnage(in: weekRange)
        if let prevRef = Calendar.iso8601.date(byAdding: .weekOfYear, value: -1, to: now()) {
            let prevRange = Calendar.iso8601WeekRange(reference: prevRef)
            let previous = try await fetchTonnage(in: prevRange)
            return makeMetric(current: current, previous: previous)
        }
        return .plain(current)
    }

    func sessionRing() async throws -> (done: Int, planned: Int) {
        let weekRange = Calendar.iso8601WeekRange(reference: now())
        let done = try await sessions.history(range: weekRange).count
        let allPlans = try await plans.plans(includeDrafts: false)
        var plannedCount = 0
        for day in weekRange.allDays {
            let weekday = Calendar.iso8601.component(.weekday, from: day)
            if allPlans.contains(where: { $0.scheduledWeekdays.contains(weekday) }) {
                plannedCount += 1
            }
        }
        return (done, max(plannedCount, done))
    }

    func latestPR() async throws -> PersonalRecord? {
        let allExercises = try await exercises.all()
        var latest: PersonalRecord?
        for exercise in allExercises {
            let prs = try await exercises.personalRecords(exerciseID: exercise.id)
            if let pr = prs.first, latest.map({ pr.date > $0.date }) ?? true {
                latest = pr
            }
        }
        return latest
    }

    // MARK: - Plan

    func estimatedDuration(planID: UUID) async throws -> TimeInterval {
        guard let plan = try await plans.find(id: planID) else { return 0 }
        let exercises = plan.planExercises.sorted { $0.order < $1.order }
        let averageSetDuration: TimeInterval = 45
        var total: TimeInterval = 0
        for ex in exercises {
            let setCount = Double(ex.planSets.count)
            total += setCount * averageSetDuration
            total += ex.restDuration * max(setCount - 1, 0)
        }
        return total
    }

    // MARK: - Private helpers

    private func fetchTonnage(in range: ClosedRange<Date>) async throws -> Double {
        try await sessions.history(range: range).reduce(0) { $0 + $1.totalTonnage }
    }

    private func previousTonnage(range: DateRange) async throws -> Double? {
        guard let prevRange = Calendar.previousRange(for: range, now: now()) else { return nil }
        return try await fetchTonnage(in: prevRange)
    }

    private func makeMetric(current: Double, previous: Double?) -> Metric {
        guard let previous else { return .plain(current) }
        let absChange = current - previous
        let percent = previous != 0 ? (absChange / previous) * 100 : nil
        return Metric(value: current, deltaPercent: percent, deltaAbsolute: absChange)
    }
}
