# Role Definition & Agent Instructions (Project: Fitness Mascot App)

Этот файл определяет роли и задачи AI-агентов (или ведущих разработчиков) для разработки мобильного приложения на Swift 6.0 / SwiftUI.

---

## Общие параметры системы

- **ОС:** iOS 18.0+
- **Архитектура:** MVVM
- **Стек:** SwiftData, SwiftUI, SwiftUI.Charts, Lottie, UserNotifications, Swift 6 (Strict Concurrency), XcodeGen, SwiftLint, Swift-format (Built-in)

---

## Доменные области

| Домен                | Ответственность                                     |
| -------------------- | --------------------------------------------------- |
| **Exercise Library** | Каталог упражнений, мышечные группы, личные рекорды |
| **Workout Planning** | Конструктор тренировок, шаблоны планов              |
| **Active Workout**   | Состояние сессии, таймеры, ввод подходов            |
| **Analytics**        | Тоннаж, история, графики прогресса                  |
| **User Profile**     | Профиль, настройки, маскот, экспорт                 |
| **Notifications**    | Локальные уведомления по окончании таймера отдыха   |

---

## Ключевые сущности (SwiftData Models)

### `MuscleGroup` — группа мышц

```swift
@Model class MuscleGroup {
    var id: UUID
    var name: String          // "Грудь", "Спина", "Ноги" …
}
```

### `Exercise` — упражнение из каталога

```swift
@Model class Exercise {
    var id: UUID
    var name: String
    var descriptionStart: String     // Исходное положение
    var descriptionExecution: String // Выполнение
    var descriptionErrors: String    // Типичные ошибки
    var muscleGroups: [MuscleGroup]  // many-to-many
    var animationAssetName: String?  // имя Lottie JSON или .mov
    @Relationship(deleteRule: .cascade)
    var personalRecords: [PersonalRecord]
}
```

### `PersonalRecord` — личный рекорд по упражнению

```swift
@Model class PersonalRecord {
    var id: UUID
    var exercise: Exercise
    var date: Date
    var weight: Double
    var reps: Int
    var tonnage: Double       // weight * reps, денормализовано для запросов
}
```

### `WorkoutPlan` — шаблон тренировки (конструктор)

```swift
@Model class WorkoutPlan {
    var id: UUID
    var name: String           // "Push Day", "Full Body" …
    var targetMuscleGroups: [MuscleGroup]
    @Relationship(deleteRule: .cascade)
    var planExercises: [PlanExercise]  // ordered list
}
```

### `PlanExercise` — упражнение внутри плана

```swift
@Model class PlanExercise {
    var id: UUID
    var plan: WorkoutPlan
    var exercise: Exercise
    var order: Int             // для Drag & Drop сортировки
    var targetSets: Int
    var restDuration: TimeInterval   // целевое время отдыха (сек)
}
```

### `WorkoutSession` — выполненная / активная тренировка

```swift
@Model class WorkoutSession {
    var id: UUID
    var plan: WorkoutPlan?     // nil для "Быстрого старта"
    var startedAt: Date
    var finishedAt: Date?      // nil пока сессия активна
    var totalTonnage: Double   // агрегат всех Set.tonnage
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet]
}
```

### `WorkoutSet` — один зафиксированный подход

```swift
@Model class WorkoutSet {
    var id: UUID
    var session: WorkoutSession
    var exercise: Exercise
    var setNumber: Int
    var weight: Double
    var reps: Int
    var tonnage: Double        // weight * reps
    var loggedAt: Date
}
```

### `UserProfile` — профиль пользователя

```swift
@Model class UserProfile {
    var id: UUID
    var name: String
    var bodyWeight: Double     // для упражнений с собственным весом
    var selectedMascotId: String
    var restSoundEnabled: Bool
    var restHapticEnabled: Bool
}
```

---

## Ключевая архитектура

```
┌─────────────────────────────────────────────────────┐
│                     SwiftUI Views                   │
│  Dashboard · ExerciseLibrary · WorkoutBuilder       │
│  ActiveWorkout · Progress · Settings                │
└──────────────────────┬──────────────────────────────┘
                       │ @Observable ViewModels
┌──────────────────────▼──────────────────────────────┐
│                   ViewModels (MVVM)                 │
│  DashboardVM · ActiveWorkoutVM · ProgressVM …       │
└──────────┬────────────────────────────┬─────────────┘
           │ Domain Services            │
┌──────────▼──────────┐   ┌────────────▼─────────────┐
│  WorkoutService     │   │  AnalyticsService        │
│  · startSession()   │   │  · weeklyTonnage()       │
│  · logSet()         │   │  · sessionHistory()      │
│  · finishSession()  │   │  · personalRecord()      │
└──────────┬──────────┘   └────────────┬─────────────┘
           │ Repositories              │
┌──────────▼───────────────────────────▼─────────────┐
│              Repository Layer                       │
│  ExerciseRepository · WorkoutRepository             │
│  SessionRepository · UserRepository                 │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│               SwiftData (ModelContext)              │
│  + UserNotifications  + Lottie Animation Layer      │
└─────────────────────────────────────────────────────┘
```

**Принципы:**

- **Model-First:** любые изменения UI начинаются с модели SwiftData.
- **Single ModelContext per Actor:** `@MainActor` для UI-операций, фоновый контекст для импорта/экспорта.
- **Tonnage как денормализованное поле:** хранится в `WorkoutSet` и агрегируется в `WorkoutSession`, чтобы избежать дорогих вычислений при построении графиков.
- **Safety:** весь код проходит проверку компилятора Swift 6 (no data races).

---

## 1. Архитектор системы (System Architect Agent)

**Цель:** Проектирование масштабируемой структуры приложения и схемы данных.

- **Зоны ответственности:**
  - Реализация SwiftData-моделей из раздела «Ключевые сущности».
  - Настройка Swift 6 Strict Concurrency и безопасности данных.
  - Реализация `ExerciseRepository`, `WorkoutRepository`, `SessionRepository`.
  - Реализация `WorkoutService` (startSession / logSet / finishSession) и `AnalyticsService`.
- **Ключевые инструкции:**
  - Использовать макросы `@Model` и `@Relationship(deleteRule: .cascade)`.
  - Обеспечить связь «один ко многим» (`WorkoutSession` → `WorkoutSet`).
  - Тоннаж рассчитывать на уровне `WorkoutService` и сохранять денормализованно.
  - Реализовать `CSVExporter` для экспорта истории тренировок (`UserProfile` → Settings).
  - Поддержка и конфигурация проекта через `project.yml` (XcodeGen).
  - Настройка правил SwiftLint и Swift-format для поддержания единообразия кода.

## 2. UI/UX Инженер (SwiftUI Specialist Agent)

**Цель:** Создание интерфейса в соответствии с Apple HIG и спецификой тренировочного процесса.

- **Зоны ответственности:**
  - **Dashboard:** горизонтальный календарь-скролл недели, виджет «Следующая тренировка», блок быстрой статистики (тоннаж, кол-во тренировок, кольцо прогресса), кнопка «Быстрый старт».
  - **Exercise Library:** поиск + фильтр-чипсы по `MuscleGroup`, список карточек, Sheet с деталями и историей `PersonalRecord`.
  - **Workout Builder:** Drag & Drop список `PlanExercise`, настройка `targetSets` и `restDuration`.
  - **Active Workout:** блок ввода (Вес + Повторения), кнопка «Выполнено», нижняя панель таймеров.
  - **Progress:** линейный график тоннажа (`SwiftUI.Charts`), список сессий с детальным отчётом.
  - **Settings:** профиль, выбор маскота, настройки уведомлений, кнопка экспорта CSV.
- **Ключевые инструкции:**
  - Dark Mode Only.
  - Крупные кнопки и поля ввода — управление одной рукой на экране Active Workout.
  - SF Symbols 6 с анимацией для таббара.
  - Haptic Feedback при логировании подхода и окончании таймера.

## 3. Специалист по анимации и ассетам (Visual & Animation Agent)

**Цель:** Интеграция анимированного маскота и управление медиа-контентом.

- **Зоны ответственности:**
  - Интеграция Lottie (JSON) или `.mov` с альфа-каналом.
  - Маппинг `Exercise.animationAssetName` → конкретный файл анимации.
  - Синхронизация состояний: `idle` (отдых), `active` (выполнение), `complete` (завершение сета).
  - Плавное «схлопывание» маскота при скролле или переходе на другой экран.
  - Настройки выбора маскота через `UserProfile.selectedMascotId`.
- **Ключевые инструкции:**
  - Маскот занимает верхнюю треть экрана Active Workout.
  - На экране Exercise Library — маскот в Sheet демонстрирует технику конкретного упражнения.
  - Анимация зациклена и плавна, оптимизирована по CPU/GPU.

## 4. Инженер по логике тренировок (Logic & Tracking Agent)

**Цель:** Управление состоянием тренировки, таймерами и вычислениями.

- **Зоны ответственности:**
  - `ActiveWorkoutViewModel`: хранит текущую `WorkoutSession`, текущий `PlanExercise`, номер сета.
  - Общий таймер тренировки (`startedAt` → now).
  - Таймер отдыха: запускается после нажатия «Выполнено», поддерживает «+15 сек».
  - Автоматический переход к следующему сету / упражнению.
  - `UserNotifications`: локальное уведомление по истечении таймера отдыха.
  - Фильтрация каталога упражнений по `MuscleGroup`.
  - Сохранение незавершённой сессии при закрытии приложения (`WorkoutSession.finishedAt == nil`).
- **Ключевые инструкции:**
  - Использовать `@Observable` + `MainActor` для таймеров, избегая data races.
  - Промежуточные `WorkoutSet` сохранять в SwiftData сразу после логирования, не в памяти.
  - При повторном открытии приложения — восстанавливать активную сессию автоматически.

---

## Инструментарий и Качество кода

- **XcodeGen:** Проект не должен содержать `.xcodeproj` в репозитории (кроме случаев временной отладки). Вся структура проекта описывается в `project.yml`. Генерация выполняется командой `xcodegen generate`.
- **SwiftLint:** Обязательное использование для статического анализа. Конфигурация в `.swiftlint.yml`. Ошибки линтера должны исправляться немедленно.
- **Swift-format:** Использование встроенного в Xcode инструмента форматирования (через Swift Package или Native Xcode settings) для автоматического приведения кода к единому стилю перед коммитом.
- **Strict Concurrency:** Все модули должны компилироваться без предупреждений Swift 6 Isolation.

---

## Протоколы взаимодействия

1. **Model-First:** Любые изменения в интерфейсе начинаются с обновления модели данных в SwiftData.
2. **Safety:** Весь код должен проходить проверку компилятора Swift 6 на отсутствие data races.
3. **No Live Activities:** Вся оперативная информация (таймеры) отображается внутри приложения или через стандартные локальные уведомления (`UserNotifications`).
4. **Tonnage First:** тоннаж (Weight × Reps) — главная метрика прогресса, денормализуется на всех уровнях модели.
