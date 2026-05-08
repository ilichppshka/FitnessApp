# Domain Layer

Сервисы и калькуляторы — оркестрация бизнес-логики поверх репозиториев.

## 1. Контракт сервисов

Все сервисы экспонируются через протоколы. Реализации внедряются через `DIContainer`.

```swift
protocol WorkoutServicing: Sendable {
    func startSession(planID: UUID?) async throws -> WorkoutSessionDTO
    func resumeActiveSession() async throws -> WorkoutSessionDTO?
    func logSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int
    ) async throws -> WorkoutSetDTO
    func finishSession(_ sessionID: UUID) async throws -> WorkoutSessionDTO
    func cancelSession(_ sessionID: UUID) async throws
}

protocol AnalyticsServicing: Sendable {
    func weeklyTonnage(reference: Date) async throws -> [DailyTonnage]
    func monthlyTonnage(reference: Date) async throws -> [WeeklyTonnage]
    func sessionHistory(limit: Int) async throws -> [WorkoutSessionDTO]
    func personalRecord(exerciseID: UUID) async throws -> PersonalRecord?
}

protocol NotificationScheduling: Sendable {
    func requestAuthorizationIfNeeded() async throws -> Bool
    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws
    func cancelRestEnd(sessionID: UUID) async
}
```

## 2. WorkoutService

Главный сервис тренировки. Отвечает за жизненный цикл `WorkoutSession`.

```swift
@MainActor
final class WorkoutService: WorkoutServicing {
    private let sessions: SessionRepository
    private let plans: WorkoutRepository
    private let exercises: ExerciseRepository

    init(sessions: SessionRepository, plans: WorkoutRepository, exercises: ExerciseRepository) {
        self.sessions = sessions
        self.plans = plans
        self.exercises = exercises
    }

    func startSession(planID: UUID?) async throws -> WorkoutSessionDTO {
        if let active = try await sessions.activeSession() {
            throw AppError.sessionAlreadyActive(id: active.id)
        }
        let session = try await sessions.create(planID: planID)
        return session
    }

    func resumeActiveSession() async throws -> WorkoutSessionDTO? {
        try await sessions.activeSession()
    }

    func logSet(
        sessionID: UUID,
        exerciseID: UUID,
        weight: Double,
        reps: Int
    ) async throws -> WorkoutSetDTO {
        guard weight >= 0, reps > 0 else { throw AppError.invalidSetInput }
        let tonnage = TonnageCalculator.compute(weight: weight, reps: reps)
        let setDTO = try await sessions.addSet(
            sessionID: sessionID,
            exerciseID: exerciseID,
            weight: weight,
            reps: reps,
            tonnage: tonnage
        )
        try await sessions.bumpTotalTonnage(sessionID: sessionID, by: tonnage)
        try await PersonalRecordCalculator.evaluateAndStoreIfNeeded(
            setDTO: setDTO,
            exercises: exercises
        )
        return setDTO
    }

    func finishSession(_ sessionID: UUID) async throws -> WorkoutSessionDTO {
        try await sessions.finish(sessionID: sessionID, at: .now)
    }

    func cancelSession(_ sessionID: UUID) async throws {
        try await sessions.delete(sessionID: sessionID)
    }
}
```

### Валидации

- `weight >= 0` (бодивейт допускается).
- `reps > 0`.
- `setNumber` присваивается репозиторием как `existingSets.count + 1` для пары (session, exercise).

### Восстановление активной сессии

При запуске приложения `AppRouter` вызывает `WorkoutService.resumeActiveSession()`. Если есть `WorkoutSession` с `finishedAt == nil` — переходим сразу на `ActiveWorkoutView` с этим ID.

## 3. AnalyticsService

```swift
struct DailyTonnage: Sendable, Identifiable, Hashable {
    let id: Date            // начало суток
    let tonnage: Double
}

struct WeeklyTonnage: Sendable, Identifiable, Hashable {
    let id: Date            // понедельник недели
    let tonnage: Double
    let sessionsCount: Int
}

@MainActor
final class AnalyticsService: AnalyticsServicing {
    private let sessions: SessionRepository
    private let exercises: ExerciseRepository

    func weeklyTonnage(reference: Date) async throws -> [DailyTonnage] {
        let range = Calendar.iso8601Week(reference: reference)
        let sessions = try await sessions.history(range: range)
        let buckets = Dictionary(grouping: sessions, by: { Calendar.startOfDay($0.startedAt) })
        return range.allDays.map { day in
            DailyTonnage(id: day, tonnage: buckets[day]?.reduce(0) { $0 + $1.totalTonnage } ?? 0)
        }
    }

    func monthlyTonnage(reference: Date) async throws -> [WeeklyTonnage] { ... }
    func sessionHistory(limit: Int) async throws -> [WorkoutSessionDTO] { ... }
    func personalRecord(exerciseID: UUID) async throws -> PersonalRecord? { ... }
}
```

> Поскольку `tonnage` денормализован, аналитика — это простые группировки, без рекурсивных fetch'ей.

## 4. TimerService

Управляет двумя таймерами: общим таймером сессии (производный от `startedAt`) и таймером отдыха.

```swift
@MainActor
@Observable
final class TimerService {
    private(set) var workoutElapsed: TimeInterval = 0
    private(set) var restRemaining: TimeInterval = 0
    private(set) var isRestRunning: Bool = false

    private var workoutTask: Task<Void, Never>?
    private var restTask: Task<Void, Never>?
    private var sessionStartedAt: Date?
    private var restEndsAt: Date?

    func startWorkout(startedAt: Date) {
        sessionStartedAt = startedAt
        workoutTask?.cancel()
        workoutTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let started = self.sessionStartedAt else { return }
                self.workoutElapsed = Date.now.timeIntervalSince(started)
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func startRest(duration: TimeInterval) {
        restEndsAt = .now.addingTimeInterval(duration)
        isRestRunning = true
        restTask?.cancel()
        restTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let ends = self.restEndsAt else { return }
                let remaining = ends.timeIntervalSinceNow
                if remaining <= 0 {
                    self.restRemaining = 0
                    self.isRestRunning = false
                    return
                }
                self.restRemaining = remaining
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    func extendRest(by seconds: TimeInterval) {
        guard let ends = restEndsAt else { return }
        restEndsAt = ends.addingTimeInterval(seconds)
    }

    func stopAll() {
        workoutTask?.cancel(); restTask?.cancel()
        workoutTask = nil; restTask = nil
        isRestRunning = false
    }
}
```

> Таймеры — на `MainActor`. Точность 250 мс достаточна для UI.
> Если приложение уходит в фон — пересчёт через `Date.now.timeIntervalSince(...)` восстанавливает корректное значение при возврате.

## 5. NotificationService

```swift
final class NotificationService: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func scheduleRestEnd(after seconds: TimeInterval, sessionID: UUID) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Отдых окончен"
        content.body = "Пора к следующему сету"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "rest-\(sessionID.uuidString)",
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelRestEnd(sessionID: UUID) async {
        center.removePendingNotificationRequests(
            withIdentifiers: ["rest-\(sessionID.uuidString)"]
        )
    }
}
```

## 6. CSVExporter

Экспорт истории тренировок: список сетов с подписью даты, упражнения, веса, повторений, тоннажа.

```swift
actor CSVExporter {
    private let sessions: SessionRepository

    func exportAll() async throws -> URL {
        let history = try await sessions.history(range: .all)
        var csv = "Date,Session,Exercise,Set,Weight,Reps,Tonnage\n"
        for session in history {
            for set in session.sets {
                csv += "\(set.loggedAt.iso),\(session.id),\(set.exerciseName),\(set.setNumber),\(set.weight),\(set.reps),\(set.tonnage)\n"
            }
        }
        let url = FileManager.default.temporaryDirectory
            .appending(path: "fitnesapp-export-\(Date.now.iso).csv")
        try csv.data(using: .utf8)?.write(to: url)
        return url
    }
}
```

`actor`, потому что не требует MainActor и работает с файлом.

## 7. Калькуляторы

Чистые функции без зависимостей — легко тестируются.

```swift
enum TonnageCalculator {
    static func compute(weight: Double, reps: Int) -> Double {
        weight * Double(reps)
    }
}

enum PersonalRecordCalculator {
    static func evaluateAndStoreIfNeeded(
        setDTO: WorkoutSetDTO,
        exercises: ExerciseRepository
    ) async throws { ... }
}
```

## 8. Обработка ошибок

```swift
enum AppError: Error, Sendable, Equatable {
    case sessionAlreadyActive(id: UUID)
    case sessionNotFound(id: UUID)
    case exerciseNotFound(id: UUID)
    case invalidSetInput
    case persistence(String)
    case notificationsDenied
}
```

ViewModel ловит `AppError`, мапит в человеко-читаемый текст для пользователя. SwiftData-ошибки оборачиваются в `AppError.persistence(...)` на уровне репозитория.

## 9. Тестирование Domain Layer

- **Mocks для репозиториев** в `Tests/Mocks/`.
- Каждый сценарий `WorkoutService` покрыт юнит-тестом: старт сессии → лог сета → финиш.
- `AnalyticsService` тестируется на сидинге сессий с известным тоннажем.
- `TonnageCalculator`, `PersonalRecordCalculator` — чистые функции, по 100% веток.
- Использовать Swift Testing: `@Test func logSet_invalidReps_throws() async throws { ... }`.
