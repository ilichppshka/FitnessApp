# Feature Modules

Декомпозиция каждого экрана: View → ViewModel → зависимости → состояние → переходы.

## 1. Dashboard

**Файлы:** `Features/Dashboard/`
**Цель:** Точка входа. Быстрый старт, виджет следующей тренировки, статистика недели.

### Состояние ViewModel

```swift
@MainActor @Observable
final class DashboardViewModel {
    private(set) var weekTonnage: [DailyTonnage]
    private(set) var weeklyTotal: Double         // Σ weekTonnage
    private(set) var sessionsThisWeek: Int
    private(set) var weeklyGoal: Double          // из UserProfile или дефолт
    private(set) var nextPlan: WorkoutPlanSummaryDTO?
    private(set) var isLoading: Bool
    private(set) var error: String?
}
```

### Действия

| Действие | Метод |
| -------- | ----- |
| Старт «быстрой» тренировки | `startQuickWorkout()` → `WorkoutService.startSession(planID: nil)` → `router.presentActiveWorkout` |
| Старт по плану | `startPlanned(planID:)` |
| Открыть детали плана | `router.dashboardPath.append(plan.id)` |

### UI-секции

1. **WeekCalendarStrip** — горизонтальный скролл недели, отметки дней с `tonnage > 0`.
2. **NextWorkoutCard** — `nextPlan?.name`, чипсы `targetMuscleGroups`, кнопка «Начать».
3. **WeeklyStatsRing** — кольцо `weeklyTotal / weeklyGoal`, цифры `display-lg`.
4. **QuickStartButton** — primary CTA с Neon Glow.

### Граничные случаи

- Нет `nextPlan` → показать пустую карточку с CTA «Создать план».
- Нет `weeklyGoal` (новый пользователь) → дефолт 10000 кг или скрыть кольцо.

---

## 2. Exercise Library

**Файлы:** `Features/ExerciseLibrary/`
**Цель:** Каталог упражнений с поиском и фильтрацией.

### Состояние

```swift
@MainActor @Observable
final class ExerciseLibraryViewModel {
    var query: String = ""
    var selectedMuscleGroups: Set<UUID> = []
    private(set) var muscleGroups: [MuscleGroupDTO] = []
    private(set) var exercises: [ExerciseDTO] = []
    private(set) var isLoading: Bool
}
```

### Действия

| Действие | Метод |
| -------- | ----- |
| Изменение поиска | `query` → debounced 250ms → `reload()` |
| Тап чипа | toggle `selectedMuscleGroups` → `reload()` |
| Тап на карточку | `router.presentedExerciseDetailID = exerciseID` |

### Детальный Sheet (`ExerciseDetailSheet`)

- `MascotStage` — Lottie/.mov анимация по `exercise.animationAssetName`.
- 3 секции описания: «Исходное положение», «Выполнение», «Ошибки».
- История `PersonalRecord`: список с датой, весом × повторениями, тоннажем.

---

## 3. Workout Builder

**Файлы:** `Features/WorkoutBuilder/`
**Цель:** Создание/редактирование `WorkoutPlan`.

### Состояние

```swift
@MainActor @Observable
final class WorkoutBuilderViewModel {
    var planID: UUID?                     // nil = новый план
    var name: String = ""
    var targetMuscleGroups: Set<UUID> = []
    private(set) var exercises: [PlanExerciseDTO] = []
    private(set) var allExercises: [ExerciseDTO] = []
    var isPickerPresented: Bool = false
}
```

### Действия

| Действие | Метод |
| -------- | ----- |
| Сохранить план | `save()` → `WorkoutRepository.upsert(...)` |
| Добавить упражнение | `addExercise(id:)` |
| Удалить упражнение | `remove(at:)` |
| Drag&drop переупорядочивание | `move(from:to:)` → пересчёт `order` |
| Изменить targetSets/restDuration | прямые setters в строке списка |

### UI

- `List` с `.onMove` для drag&drop.
- Каждая строка: название + Stepper для `targetSets` + поле `restDuration`.
- Кнопка `+ Добавить упражнение` открывает `Sheet` со списком из каталога (упрощённый `ExerciseLibraryView`).

---

## 4. Active Workout

**Файлы:** `Features/ActiveWorkout/`
**Цель:** Управление активной тренировкой.

### Состояние

```swift
@MainActor @Observable
final class ActiveWorkoutViewModel {
    let sessionID: UUID
    private(set) var session: WorkoutSessionDTO?
    private(set) var planExercises: [PlanExerciseDTO] = []   // если plan != nil
    private(set) var currentExerciseIndex: Int = 0
    private(set) var currentSetNumber: Int = 1
    var weightInput: String = ""
    var repsInput: String = ""
    var error: String?
    // Прокси к TimerService:
    var workoutElapsed: TimeInterval { ... }
    var restRemaining: TimeInterval { ... }
    var isResting: Bool { ... }
}
```

### Жизненный цикл

```
appear()
  ├─ session = workoutService.session(by: sessionID)
  ├─ timers.startWorkout(startedAt: session.startedAt)
  └─ восстановить currentExerciseIndex / currentSetNumber из session.sets

logSet()
  ├─ валидация weightInput, repsInput
  ├─ workoutService.logSet(...)
  ├─ Haptic feedback (.success)
  ├─ если currentSetNumber < planExercise.targetSets:
  │     timers.startRest(duration: planExercise.restDuration)
  │     notifications.scheduleRestEnd(after:..., sessionID:)
  ├─ иначе: skipToNextExercise()
  └─ очистить weightInput, repsInput

finish()
  ├─ timers.stopAll()
  ├─ notifications.cancelRestEnd(sessionID:)
  ├─ workoutService.finishSession(sessionID)
  └─ router.dismissActiveWorkout()
```

### UI-секции

1. **MascotStage** — верхняя треть, Lottie/.mov, реагирует на `isResting`.
2. **ExerciseHeader** — название, «Сет 2 из 4».
3. **SetInputPanel** — две клавиатурные ячейки + кнопка «Выполнено» (Neon Glow).
4. **RestTimerBar** — нижняя панель: «Тренировка XX:XX» / «Отдых XX:XX +15» / «Завершить».

### Восстановление

При запуске приложения, если `WorkoutService.resumeActiveSession()` вернул сессию — `AppRouter` показывает `ActiveWorkoutScreen` поверх таб-бара. ViewModel восстанавливает состояние сетов из БД.

---

## 5. Progress

**Файлы:** `Features/Progress/`
**Цель:** Аналитика и история.

### Состояние

```swift
@MainActor @Observable
final class ProgressViewModel {
    enum Range: Hashable { case week, month, threeMonths }
    var selectedRange: Range = .week
    private(set) var chartData: [DailyTonnage] = []
    private(set) var history: [WorkoutSessionDTO] = []
    private(set) var isLoading: Bool
}
```

### UI

- **Range Selector** — segmented `Picker`.
- **TonnageChart** — `Chart { LineMark(...) }` из Swift Charts. Линия `primary` цвета с Neon Glow на последней точке.
- **SessionHistoryList** — список сессий, сортировка по `startedAt` desc. Тап → детальный отчёт (отдельный экран в navigation stack: список сетов + итоговый тоннаж).

### Действия

| Действие | Метод |
| -------- | ----- |
| Смена диапазона | `selectedRange = .month` → `reload()` |
| Тап сессии | `router.progressPath.append(session.id)` → `SessionDetailView` |

---

## 6. Settings

**Файлы:** `Features/Settings/`
**Цель:** Профиль, маскот, уведомления, экспорт.

### Состояние

```swift
@MainActor @Observable
final class SettingsViewModel {
    var profile: UserProfileDTO?
    var availableMascots: [MascotID] = MascotID.allCases
    private(set) var exportURL: URL?
    var error: String?
}
```

### Действия

| Действие | Метод |
| -------- | ----- |
| Сохранить имя/вес | `updateProfile()` → `UserRepository.update` |
| Сменить маскот | `selectMascot(_:)` |
| Тоггл звука/вибрации | `setRestSoundEnabled(_:)`, `setRestHapticEnabled(_:)` |
| Экспорт CSV | `export()` → `CSVExporter.exportAll()` → `ShareSheet` через `exportURL` |

### UI

- Form с секциями: «Профиль», «Маскот», «Уведомления», «Данные».
- Toggle с primary glow в состоянии ON (см. design-system).
- Карусель маскотов — горизонтальный скролл с текущим выделением.

---

## 7. Общие компоненты экранов

| Компонент | Где используется | Файл |
| --------- | ---------------- | ---- |
| `MuscleGroupChip` | Library, Builder, Dashboard | `Features/ExerciseLibrary/Components/` |
| `MascotStage` | ActiveWorkout, ExerciseDetail | `DesignSystem/Components/` |
| `KineticButton` | везде | `DesignSystem/Components/` |
| `PerformanceCard` | Dashboard, History | `DesignSystem/Components/` |
| `FloatingNavPill` | TabBar | `DesignSystem/Components/` |
| `RestTimerBar` | ActiveWorkout | `Features/ActiveWorkout/Components/` |

## 8. Карта переходов

```
Dashboard
  ├─ [Quick Start] ─────────────────► ActiveWorkout (fullScreenCover)
  ├─ [Plan Card → Start] ───────────► ActiveWorkout (fullScreenCover)
  └─ [Plan Card → tap] ─────────────► WorkoutBuilder (push)

ExerciseLibrary
  └─ [card tap] ────────────────────► ExerciseDetail (sheet)

WorkoutBuilder
  └─ [+ Add Exercise] ──────────────► ExercisePicker (sheet)

Progress
  └─ [session row] ─────────────────► SessionDetail (push)

Settings
  └─ [Export CSV] ──────────────────► ShareSheet (system)
```

`ActiveWorkout` всегда `fullScreenCover` поверх таб-бара — пользователь не теряет сессию при переключении.
