# KINETIC — Services & Repositories (Domain Layer)

Описание доменного слоя приложения **KINETIC**: репозитории (доступ к данным) и сервисы (бизнес-логика), выведенные из экранов в [userflow.md](userflow.md). Опирается на схему из [models.md](models.md) и слой данных из [data-layer.md](data-layer.md). Роли агентов и принципы — в [AGENTS.md](../AGENTS.md).

> **Канон:** модели — [models.md](models.md); реализация `ModelContainer` / DTO / сидинга — [data-layer.md](data-layer.md); сценарии экранов — [userflow.md](userflow.md). Этот файл — справочник по **сервисам и репозиториям** и их API.

---

## 0. Принципы доменного слоя

- **Swift 6, Strict Concurrency.** Никаких data races; асинхронный API (`async throws`).
- **Репозиторий — единственный владелец `ModelContext`.** Только он делает `fetch` / `insert` / `save`. Сервисы и ViewModel'и работают через репозитории.
- **`@MainActor` для UI-операций.** Репозитории и большинство сервисов привязаны к главному актору (один `ModelContext` на UI). Тяжёлые операции (CSV-экспорт, сидинг) — фоновый контекст.
- **Сервис оркеструет, репозиторий хранит.** Бизнес-правила (расчёт tonnage, детект PR, прогрессия, агрегаты) — в сервисах; CRUD и запросы — в репозиториях.
- **DTO на границе актора.** Если данные уходят с `@MainActor` (фон, кэш для UI без живой связи с контекстом) — отдаём Sendable-DTO (см. [data-layer.md · §5](data-layer.md#5-dto)).
- **Tonnage First.** `tonnage = weight × reps` считается в `WorkoutService` при логировании и денормализуется в `WorkoutSet` / `WorkoutSession`.
- **No Live Activities.** Таймеры — внутри приложения; уведомления — только локальные (`UserNotifications`).

---

## 1. Карта слоёв

```
┌─────────────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                             │
│  Onboarding · Dashboard · Library · Detail · Builder ·       │
│  ActiveWorkout · Progress · Settings                         │
└───────────────────────────┬─────────────────────────────────┘
                            │ @Observable ViewModels
┌───────────────────────────▼─────────────────────────────────┐
│  Services (бизнес-логика)                                    │
│  WorkoutService · AnalyticsService · ProgressionService ·    │
│  RestTimerService · NotificationService · HapticsService ·   │
│  CSVExporter · DataSeeder                                     │
└───────────────────────────┬─────────────────────────────────┘
                            │ через протоколы репозиториев
┌───────────────────────────▼─────────────────────────────────┐
│  Repositories (доступ к данным)                              │
│  UserRepository · ExerciseRepository ·                       │
│  WorkoutRepository · SessionRepository                       │
└───────────────────────────┬─────────────────────────────────┘
                            │ ModelContext
┌───────────────────────────▼─────────────────────────────────┐
│  SwiftData  +  UserNotifications  +  Lottie                  │
└─────────────────────────────────────────────────────────────┘
```

**Сводка зависимостей сервисов:**

| Сервис | Зависит от |
| --- | --- |
| `WorkoutService` | `SessionRepository`, `ExerciseRepository`, `UserRepository`, `ProgressionService` |
| `AnalyticsService` | `SessionRepository`, `ExerciseRepository`, `WorkoutRepository` |
| `ProgressionService` | `SessionRepository`, `ExerciseRepository` |
| `RestTimerService` | `UserRepository` (autoStart / длительность), `NotificationService`, `HapticsService` |
| `NotificationService` | `UNUserNotificationCenter` |
| `HapticsService` | `UserRepository` (`restHapticEnabled`) |
| `CSVExporter` | `SessionRepository` (фоновый контекст) |
| `DataSeeder` | `ModelContext` (см. [data-layer.md · §6](data-layer.md#6-сидинг-каталога)) |

---

## 2. Репозитории

Канонический набор — **4 репозитория** (как в [AGENTS.md](../AGENTS.md) и [data-layer.md · §4](data-layer.md#4-repositories)). Каждый — протокол `Sendable` + реализация `@MainActor final class SwiftData…Repository`. Возвращают доменные модели (на `@MainActor`) или DTO (на границе актора).

### 2.1. `UserRepository` — профиль и настройки

Единственный `UserProfile` (singleton). Используется на Profile Setup и Settings.

```swift
protocol UserRepository: Sendable {
    /// Текущий профиль; при отсутствии создаёт дефолтный (weightUnit = .kg, маскот "duck").
    func current() async throws -> UserProfile
    /// Мутация профиля в транзакции + save.
    func update(_ mutate: @MainActor (UserProfile) -> Void) async throws
    func exists() async throws -> Bool          // ветвление cold start
}
```

| Экран | Использование |
| --- | --- |
| Profile Setup | создание `UserProfile` (имя, вес, единица, маскот) |
| Settings · TRAINING | `defaultRestDuration`, `weightUnit`, `autoStartRestTimer` |
| Settings · NOTIFICATIONS | `restSoundEnabled`, `restHapticEnabled` |
| Settings · Mascot Picker | `selectedMascotId` |

> Флаг «онбординг пройден» — `@AppStorage("onboardingCompleted")`, не в модели; наличие профиля = настройка завершена.

### 2.2. `ExerciseRepository` — каталог, мышцы, избранное, PR

Каталог упражнений, фильтр-чипсы по `MuscleGroup`, избранное, чтение `PersonalRecord`.

```swift
protocol ExerciseRepository: Sendable {
    func all() async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]

    func muscleGroups() async throws -> [MuscleGroup]      // фильтр-чипсы (Chest…Core)
    func exerciseOfTheDay() async throws -> Exercise?       // featured-карточка
    func recent(limit: Int) async throws -> [Exercise]      // блок RECENT (из истории сетов)

    func favorites() async throws -> [Exercise]
    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws   // ⭐ тоггл

    func personalRecords(exerciseID: UUID) async throws -> [PersonalRecord]  // вкладка PRs/History
}
```

| Экран | Использование |
| --- | --- |
| Library | `search`, `muscleGroups`, `exerciseOfTheDay`, `recent` |
| Exercise Detail | `find`, `personalRecords`, `setFavorite` |
| Workout Builder / Active | `all` / `find` при добавлении упражнения |

> Реализацию `search` (предикат + фильтр по `muscleLinks`) и `setFavorite` см. в [data-layer.md · §4](data-layer.md#4-repositories).

### 2.3. `WorkoutRepository` — планы (конструктор)

CRUD планов, drag&drop порядок, черновики (`isDraft`). Обслуживает Workout Builder и подбор плана дня на Dashboard.

```swift
protocol WorkoutRepository: Sendable {
    func plans(includeDrafts: Bool) async throws -> [WorkoutPlan]
    func find(id: UUID) async throws -> WorkoutPlan?
    func scheduled(weekday: Int) async throws -> [WorkoutPlan]   // Next session / week strip

    func createDraft() async throws -> WorkoutPlan               // авто-сохранение черновика
    func upsert(_ planID: UUID, mutate: @MainActor (WorkoutPlan) -> Void) async throws
    func publish(_ planID: UUID) async throws                    // isDraft = false (Save Plan)
    func remove(_ planID: UUID) async throws

    // структура плана
    func addExercise(_ exerciseID: UUID, to planID: UUID) async throws -> PlanExercise
    func removeExercise(_ planExerciseID: UUID) async throws
    func reorder(planID: UUID, from: IndexSet, to: Int) async throws   // пересчёт PlanExercise.order
    func setPlanSets(_ sets: [PlanSetDraft], for planExerciseID: UUID) async throws
    func setRest(_ duration: TimeInterval, for planExerciseID: UUID) async throws
}
```

| Экран | Использование |
| --- | --- |
| Workout Builder | весь CRUD: `createDraft`, `addExercise`, `reorder`, `setPlanSets`, `setRest`, `publish` |
| Dashboard | `scheduled(weekday:)` → hero «Next session»; `plans` → список планов |

> `reorder` — batch-пересчёт `PlanExercise.order`; `updatedAt` обновляется при любой мутации (статус «Auto-saved · 12s ago»).

### 2.4. `SessionRepository` — сессии и подходы

Активная сессия, логирование сетов, история завершённых сессий, очистка.

```swift
protocol SessionRepository: Sendable {
    func activeSession() async throws -> WorkoutSession?              // restore (finishedAt == nil)
    func create(planID: UUID?, title: String) async throws -> WorkoutSession
    @discardableResult
    func appendSet(_ draft: WorkoutSetDraft, to sessionID: UUID) async throws -> WorkoutSet
    func finish(_ sessionID: UUID, at date: Date, totalTonnage: Double) async throws
    func discard(_ sessionID: UUID) async throws                     // отмена без сохранения

    func history(range: DateRange) async throws -> [WorkoutSession]   // только finishedAt != nil
    func find(id: UUID) async throws -> WorkoutSession?               // Session Detail
    func lastSet(exerciseID: UUID) async throws -> WorkoutSet?        // прогрессия / "Last set"
    func clearHistory() async throws                                  // Settings · Clear history
}
```

| Экран | Использование |
| --- | --- |
| Cold start | `activeSession` → восстановление Active Workout |
| Active Workout | `create`, `appendSet`, `finish` / `discard`, `lastSet` |
| Progress | `history(range:)`, список Recent Sessions |
| Session Detail | `find(id:)` (read-only) |
| Settings · DATA | `clearHistory` |

> `appendSet` сохраняет `WorkoutSet` **сразу** (не в памяти) — гарантия восстановления при закрытии приложения. Вспомогательные draft-структуры (`PlanSetDraft`, `WorkoutSetDraft`) — Sendable-параметры мутаций.

---

## 3. Сервисы

### 3.1. `WorkoutService` — жизненный цикл сессии

Центральный сервис Active Workout: старт/возобновление, логирование сета с расчётом tonnage и детектом PR, финализация с агрегацией.

```swift
@MainActor
final class WorkoutService {
    init(sessions: SessionRepository,
         exercises: ExerciseRepository,
         user: UserRepository,
         progression: ProgressionService)

    func startSession(planID: UUID?) async throws -> WorkoutSession   // planID == nil → Quick Start
    func resumeActiveSession() async throws -> WorkoutSession?        // при cold start

    /// Создаёт WorkoutSet (tonnage = weight×reps), сохраняет сразу,
    /// детектит PR → выставляет isPersonalRecord и при необходимости создаёт PersonalRecord.
    @discardableResult
    func logSet(sessionID: UUID, exerciseID: UUID,
                weight: Double, reps: Int) async throws -> WorkoutSet

    func finishSession(_ sessionID: UUID) async throws   // finishedAt = .now, totalTonnage = Σ sets
    func discardSession(_ sessionID: UUID) async throws
}
```

**Правило детекта PR (`logSet`):** новый сет считается рекордом, если его `Est. 1RM` (формула Epley, см. `AnalyticsService`) превышает лучший среди существующих `PersonalRecord` упражнения. Тогда `WorkoutSet.isPersonalRecord = true` и создаётся `PersonalRecord`. Это поднимает бейдж `PR` на Progress (`WorkoutSession.containsPR`) и виджет Latest PR на Dashboard.

### 3.2. `ProgressionService` — рекомендация следующего подхода

Подсказка веса/повторов и подтяжка прошлого результата на Active Workout (решение #6 в [userflow.md · §10](userflow.md#10-сводка-расхождений-с-agentsmd-решения-зафиксированы)).

```swift
struct ProgressionSuggestion: Sendable {
    let suggestedWeight: Double      // WEIGHT 75 kg
    let suggestedReps: Int
    let deltaVsLast: Double          // "↑ +5kg"
    let lastSet: WorkoutSetDTO?      // "Last set: 70kg × 10"
}

protocol ProgressionService: Sendable {
    func suggestion(exerciseID: UUID,
                    planExercise: PlanExercise?) async throws -> ProgressionSuggestion
}
```

**Эвристика:** берём последний `WorkoutSet` по упражнению (`SessionRepository.lastSet`); если повторы достигли верха целевого диапазона (`PlanExercise.targetRepMax`) — рекомендуем шаг вверх по весу (инкремент зависит от `equipment`), иначе повторяем вес и целимся в больший rep. При отсутствии истории — `PlanSet.targetWeight` / `targetReps`.

### 3.3. `RestTimerService` — таймер отдыха

UI-привязанный (`@Observable`) state-machine таймера между подходами: `−15s / +15s / Skip`, авто-старт по `UserProfile.autoStartRestTimer`. По окончании — локальное уведомление + хаптик.

```swift
@Observable
@MainActor
final class RestTimerService {
    private(set) var total: TimeInterval = 0
    private(set) var remaining: TimeInterval = 0
    private(set) var isRunning = false
    var progress: Double { total > 0 ? 1 - remaining / total : 0 }   // прогресс-бар (58%)

    init(notifications: NotificationService, haptics: HapticsService, user: UserRepository)

    func start(duration: TimeInterval)   // после Complete Set (или авто-старт)
    func adjust(by seconds: TimeInterval) // ±15s
    func skip()                           // обнулить, перейти к следующему сету
    func pause(); func resume()
}
```

> При `start` планируется уведомление `scheduleRestEnd(after:)`; при `skip`/`adjust` — переплан/отмена. По завершении (`remaining == 0`) — `haptics.play(.restDone)` и снятие баннера.

### 3.4. `NotificationService` — локальные уведомления

Обёртка над `UNUserNotificationCenter`. Запрос прав — на Profile Setup; уведомление по окончании отдыха (если `restSoundEnabled`). **Без Live Activities.**

```swift
protocol NotificationService: Sendable {
    func requestAuthorization() async -> Bool             // Profile Setup
    func scheduleRestEnd(after seconds: TimeInterval, soundEnabled: Bool) async
    func cancelRestEnd() async
}
```

### 3.5. `HapticsService` — тактильный фидбек

Хаптик при логировании подхода и окончании таймера; уважает `UserProfile.restHapticEnabled`.

```swift
enum HapticKind { case setLogged, restDone, personalRecord }

@MainActor
protocol HapticsService {
    func play(_ kind: HapticKind)
}
```

### 3.6. `AnalyticsService` — метрики и агрегаты

Всё, что **не хранится** и вычисляется по истории (см. [models.md · §4](models.md#4-что-не-хранится-вычисляется)): тоннаж за период с дельтой, ряды для графика, серия (streak), новые PR, `Est. 1RM`, `Attempts`, состояния дней недели и быстрая статистика Dashboard.

```swift
enum DateRange: CaseIterable { case week, month, threeMonths, year, all }  // range-табы Progress

struct Metric: Sendable {            // значение + дельта к предыдущему периоду
    let value: Double
    let deltaPercent: Double?         // "+18.2% vs previous"
    let deltaAbsolute: Double?        // "+2", "+1h"
}

struct TonnagePoint: Sendable { let date: Date; let tonnage: Double }      // SwiftUI.Charts
enum DayState: Sendable { case done, today, planned, rest }                // week strip

protocol AnalyticsService: Sendable {
    // — Progress —
    func totalTonnage(range: DateRange) async throws -> Metric
    func tonnageSeries(range: DateRange) async throws -> [TonnagePoint]
    func sessionsCount(range: DateRange) async throws -> Metric
    func totalTime(range: DateRange) async throws -> Metric
    func newPRsCount(range: DateRange) async throws -> Metric
    func currentStreak() async throws -> Int

    // — Exercise Detail —
    func estimatedOneRepMax(exerciseID: UUID) async throws -> Double?   // Epley по лучшему PR
    func attempts(exerciseID: UUID) async throws -> Int                 // count(WorkoutSet)

    // — Dashboard —
    func weekStates(weekOf date: Date) async throws -> [DayState]       // done/today/planned/rest
    func weeklyVolume() async throws -> Metric                          // THIS WEEK + дельта
    func sessionRing() async throws -> (done: Int, planned: Int)        // "3/5 sessions"
    func latestPR() async throws -> PersonalRecord?                     // виджет Latest PR

    // — Plan —
    func estimatedDuration(planID: UUID) async throws -> TimeInterval   // EST. TIME
}
```

> `Est. 1RM` — формула Epley: `weight × (1 + reps/30)`. Дельты считаются сравнением текущего диапазона с равным предыдущим. `streak` — последовательные дни/сессии до сегодня.

### 3.7. `CSVExporter` — экспорт истории

Экспорт завершённых сессий/подходов в CSV (Settings · DATA → `Export to CSV`). Тяжёлая операция — на **фоновом** `ModelContext`, результат — файл для ShareSheet.

```swift
protocol CSVExporter: Sendable {
    func exportHistory() async throws -> URL   // пишет CSV во временную папку, возвращает URL
}
```

> Колонки: `date, session, exercise, set, weight, reps, tonnage, isPR`. Единица веса — из `UserProfile.weightUnit`.

### 3.8. `DataSeeder` — сидинг каталога

Базовые `MuscleGroup` + `Exercise` (со связями `ExerciseMuscle`) при первом запуске. Реализация — в [data-layer.md · §6](data-layer.md#6-сидинг-каталога). Вызывается из бутстрапа приложения после создания `ModelContainer`, до показа Library.

---

## 4. Сквозные вопросы

- **Concurrency.** Репозитории и UI-сервисы — `@MainActor` (общий `ModelContext`). `CSVExporter` и `DataSeeder` могут работать на фоновом контейнере/`ModelActor`; результат отдают через Sendable-типы (URL, DTO).
- **Композиция / DI.** Единая точка сборки графа зависимостей; инжектится в SwiftUI через `Environment`.

```swift
@MainActor
final class AppServices {
    let user: UserRepository
    let exercises: ExerciseRepository
    let plans: WorkoutRepository
    let sessions: SessionRepository

    let workout: WorkoutService
    let analytics: AnalyticsService
    let progression: ProgressionService
    let restTimer: RestTimerService
    let notifications: NotificationService
    let haptics: HapticsService
    let csv: CSVExporter

    init(context: ModelContext) { /* собирает репозитории из context, сервисы из репозиториев */ }
}
```

- **Ошибки.** Доменные ошибки — типизированные (`enum WorkoutError`, `enum DataError`); репозитории пробрасывают ошибки SwiftData, сервисы оборачивают в доменные.
- **Тестирование.** In-memory `ModelContainer` (`makePreview`) + фикстуры; мок-репозитории за протоколами для юнит-тестов сервисов (`AnalyticsService` дельты/streak, `WorkoutService` детект PR, `ProgressionService` эвристика). См. [data-layer.md · §8](data-layer.md#8-тестирование-data-layer).

---

## 5. Экран → сервисы/репозитории

| Экран | ViewModel | Сервисы / репозитории |
| --- | --- | --- |
| **Onboarding** | `OnboardingVM` | `@AppStorage` (флаг), `NotificationService` (на след. шаге) |
| **Profile Setup** | `ProfileSetupVM` | `UserRepository.update`, `NotificationService.requestAuthorization` |
| **Dashboard** | `DashboardVM` | `AnalyticsService` (weekStates, weeklyVolume, sessionRing, latestPR), `WorkoutRepository.scheduled`, `WorkoutService.startSession` |
| **Library** | `LibraryVM` | `ExerciseRepository` (search, muscleGroups, exerciseOfTheDay, recent) |
| **Exercise Detail** | `ExerciseDetailVM` | `ExerciseRepository` (find, personalRecords, setFavorite), `AnalyticsService` (estimatedOneRepMax, attempts) |
| **Workout Builder** | `WorkoutBuilderVM` | `WorkoutRepository` (createDraft, addExercise, reorder, setPlanSets, setRest, publish), `AnalyticsService.estimatedDuration` |
| **Active Workout** | `ActiveWorkoutVM` | `WorkoutService` (start/log/finish), `ProgressionService`, `RestTimerService`, `NotificationService`, `HapticsService` |
| **Progress** | `ProgressVM` | `AnalyticsService` (все range-метрики, серии), `SessionRepository.history` |
| **Session Detail** | `SessionDetailVM` | `SessionRepository.find` (read-only) |
| **Settings** | `SettingsVM` | `UserRepository.update`, `CSVExporter.exportHistory`, `SessionRepository.clearHistory` |

---

## 6. Вне области v1 (на будущее)

Согласовано с [models.md · §6](models.md#6-вне-области-v1-на-будущее):

- **`AuthService`** — вход через **Telegram ID (OAuth)**; появится при добавлении `telegramUserId` / `email` в `UserProfile`.
- **`HealthKitService`** — синхронизация с Apple Health (`Apple Health Connected` в Settings).
- **`ProgramService`** — программы/мезоциклы («WEEK 3»); сейчас расписание — через `WorkoutPlan.scheduledWeekdays`.
- **`EmailService`** — `Weekly summary email`.
