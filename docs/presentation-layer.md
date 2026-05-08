# Presentation Layer

SwiftUI Views, ViewModels, навигация, состояние.

## 1. Принципы

- **MVVM.** View ↔ `@Observable` ViewModel. View не делает запросов к репозиториям/сервисам напрямую.
- **ViewModel — чистый Swift.** Не импортирует `SwiftUI`. Ни `View`, ни `EnvironmentObject`. Это делает их легко тестируемыми.
- **`@MainActor`** для всех ViewModel — UI-обновления и таймеры на главном потоке.
- **Navigation State** живёт в `AppRouter` (корневое `@Observable`-состояние), а не разбросан по экранам.
- **Sendable DTO** на границах. ViewModel хранит `[ExerciseDTO]`, а не `[Exercise]` — это уже не SwiftData-объекты, поэтому безопасны для копирования и сравнения.

## 2. AppRouter

```swift
@Observable
@MainActor
final class AppRouter {
    enum Tab: Hashable { case dashboard, library, progress, settings }
    var selectedTab: Tab = .dashboard

    var dashboardPath = NavigationPath()
    var libraryPath = NavigationPath()
    var progressPath = NavigationPath()
    var settingsPath = NavigationPath()

    var presentedActiveSessionID: UUID?    // Полноэкранный модаль ActiveWorkout
    var presentedExerciseDetailID: UUID?   // Sheet с деталями упражнения
    var presentedBuilderPlanID: UUID?      // Sheet/Stack для конструктора

    func presentActiveWorkout(sessionID: UUID) { presentedActiveSessionID = sessionID }
    func dismissActiveWorkout() { presentedActiveSessionID = nil }
}
```

Экран `ActiveWorkout` показывается через `.fullScreenCover` поверх таб-бара — пользователь не должен случайно потерять активную сессию.

## 3. DI Container

Конструкторная инъекция. Инициализируется в `FitnesAppApp` и пробрасывается в SwiftUI через `.environment(...)`.

```swift
@MainActor
@Observable
final class DIContainer {
    let workoutService: any WorkoutServicing
    let analyticsService: any AnalyticsServicing
    let notificationService: any NotificationScheduling
    let timerService: TimerService
    let csvExporter: CSVExporter
    let exerciseRepository: any ExerciseRepository
    let sessionRepository: any SessionRepository
    let userRepository: any UserRepository

    init(modelContext: ModelContext) {
        let exerciseRepo = SwiftDataExerciseRepository(context: modelContext)
        let sessionRepo = SwiftDataSessionRepository(context: modelContext)
        let planRepo = SwiftDataWorkoutRepository(context: modelContext)
        let userRepo = SwiftDataUserRepository(context: modelContext)

        self.exerciseRepository = exerciseRepo
        self.sessionRepository = sessionRepo
        self.userRepository = userRepo
        self.workoutService = WorkoutService(
            sessions: sessionRepo, plans: planRepo, exercises: exerciseRepo
        )
        self.analyticsService = AnalyticsService(
            sessions: sessionRepo, exercises: exerciseRepo
        )
        self.notificationService = NotificationService()
        self.timerService = TimerService()
        self.csvExporter = CSVExporter(sessions: sessionRepo)
    }
}
```

ViewModel получает зависимости через инициализатор:

```swift
@MainActor
init(workout: any WorkoutServicing, analytics: any AnalyticsServicing) { ... }
```

В превью используется `DIContainer.preview` с in-memory контейнером и сидингом фикстур.

## 4. Корневая View

```swift
@main
struct FitnesAppApp: App {
    @State private var container: DIContainer
    @State private var router = AppRouter()
    private let modelContainer: ModelContainer

    init() {
        let mc = try! ModelContainer.makeProduction()
        self.modelContainer = mc
        let context = ModelContext(mc)
        try? DataSeeder.seedIfNeeded(context)
        self._container = State(initialValue: DIContainer(modelContext: context))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(router)
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
                .task { await bootstrap() }
        }
    }

    private func bootstrap() async {
        _ = try? await container.notificationService.requestAuthorizationIfNeeded()
        if let active = try? await container.workoutService.resumeActiveSession() {
            router.presentActiveWorkout(sessionID: active.id)
        }
    }
}
```

## 5. RootView и табы

```swift
struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            DashboardScreen().tag(AppRouter.Tab.dashboard)
                .tabItem { Label("Главная", systemImage: "house") }
            ExerciseLibraryScreen().tag(AppRouter.Tab.library)
                .tabItem { Label("Каталог", systemImage: "books.vertical") }
            ProgressScreen().tag(AppRouter.Tab.progress)
                .tabItem { Label("Прогресс", systemImage: "chart.line.uptrend.xyaxis") }
            SettingsScreen().tag(AppRouter.Tab.settings)
                .tabItem { Label("Настройки", systemImage: "gearshape") }
        }
        .fullScreenCover(item: Binding(
            get: { router.presentedActiveSessionID.map(IdentifiableUUID.init) },
            set: { router.presentedActiveSessionID = $0?.id }
        )) { id in
            ActiveWorkoutScreen(sessionID: id.id)
        }
    }
}
```

Таб-бар оформляется как «Floating Navigation Pill» (см. `design-system.md`).

## 6. Шаблон ViewModel

```swift
@Observable
@MainActor
final class DashboardViewModel {
    private let workout: any WorkoutServicing
    private let analytics: any AnalyticsServicing
    private let plans: any WorkoutRepository
    private let router: AppRouter

    private(set) var weekTonnage: [DailyTonnage] = []
    private(set) var nextPlan: WorkoutPlanSummaryDTO?
    private(set) var sessionsThisWeek: Int = 0
    private(set) var isLoading: Bool = false
    private(set) var error: String?

    init(workout: any WorkoutServicing, analytics: any AnalyticsServicing,
         plans: any WorkoutRepository, router: AppRouter) {
        self.workout = workout; self.analytics = analytics
        self.plans = plans; self.router = router
    }

    func load() async {
        isLoading = true; defer { isLoading = false }
        do {
            async let week = analytics.weeklyTonnage(reference: .now)
            async let plan = plans.nextSuggested()
            self.weekTonnage = try await week
            self.nextPlan = try await plan
            self.sessionsThisWeek = self.weekTonnage.filter { $0.tonnage > 0 }.count
        } catch {
            self.error = humanReadable(error)
        }
    }

    func startQuickWorkout() async {
        do {
            let session = try await workout.startSession(planID: nil)
            router.presentActiveWorkout(sessionID: session.id)
        } catch {
            self.error = humanReadable(error)
        }
    }

    func startPlanned(planID: UUID) async {
        do {
            let session = try await workout.startSession(planID: planID)
            router.presentActiveWorkout(sessionID: session.id)
        } catch { self.error = humanReadable(error) }
    }
}
```

### Загрузка состояния (`load()`)

- Вызывается в `.task` модификаторе View.
- Не использует `onAppear` (несовместим со структурированной concurrency).
- Реакция на возвращение из фона — через `@Environment(\.scenePhase)`.

## 7. ActiveWorkoutViewModel — особый случай

Хранит больше всего состояния, координирует таймеры и логирование.

```swift
@Observable
@MainActor
final class ActiveWorkoutViewModel {
    let sessionID: UUID
    private let workout: any WorkoutServicing
    private let timers: TimerService
    private let notifications: any NotificationScheduling

    private(set) var session: WorkoutSessionDTO?
    private(set) var currentExercise: PlanExerciseDTO?
    private(set) var currentSetNumber: Int = 1
    var weightInput: String = ""
    var repsInput: String = ""
    private(set) var error: String?

    var workoutElapsed: TimeInterval { timers.workoutElapsed }
    var restRemaining: TimeInterval { timers.restRemaining }
    var isResting: Bool { timers.isRestRunning }

    func appear() async { ... }                // Загружает сессию + стартует workout-таймер
    func logSet() async { ... }                // Валидация → workout.logSet() → старт rest + notification
    func extendRest(by seconds: TimeInterval) { timers.extendRest(by: seconds); /* перепланировать notification */ }
    func skipToNextExercise() { ... }
    func finish() async { ... }                // Останавливает таймеры, закрывает сессию
}
```

## 8. View ↔ ViewModel связка

```swift
struct DashboardScreen: View {
    @Environment(DIContainer.self) private var di
    @Environment(AppRouter.self) private var router
    @State private var vm: DashboardViewModel?

    var body: some View {
        Group {
            if let vm {
                DashboardContent(vm: vm)
            } else {
                ProgressView()
            }
        }
        .task {
            if vm == nil {
                vm = DashboardViewModel(
                    workout: di.workoutService,
                    analytics: di.analyticsService,
                    plans: di.workoutRepository,
                    router: router
                )
            }
            await vm?.load()
        }
    }
}
```

Создание `vm` через `@State` — гарантирует одну инстанцию на жизненный цикл View.

## 9. Карта экранов → ViewModels

| Экран | ViewModel | Зависит от |
| ----- | --------- | ---------- |
| Dashboard | `DashboardViewModel` | `WorkoutServicing`, `AnalyticsServicing`, `WorkoutRepository` |
| Exercise Library | `ExerciseLibraryViewModel` | `ExerciseRepository` |
| Exercise Detail | `ExerciseDetailViewModel` | `ExerciseRepository`, `AnalyticsServicing` |
| Workout Builder | `WorkoutBuilderViewModel` | `WorkoutRepository`, `ExerciseRepository` |
| Active Workout | `ActiveWorkoutViewModel` | `WorkoutServicing`, `TimerService`, `NotificationScheduling` |
| Progress | `ProgressViewModel` | `AnalyticsServicing` |
| Settings | `SettingsViewModel` | `UserRepository`, `CSVExporter`, `NotificationScheduling` |

Подробнее каждый экран — в [feature-modules.md](feature-modules.md).

## 10. Превью

Каждая View имеет `#Preview` с in-memory `DIContainer.preview`:

```swift
#Preview("Dashboard") {
    DashboardScreen()
        .environment(DIContainer.preview)
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
```

`DIContainer.preview` сидит фикстуры (3 плана, 20 упражнений, 5 завершённых сессий с известным тоннажем).
