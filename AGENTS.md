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

## User Flow

Полный пользовательский флоу приложения. Является точкой опоры при реализации навигации (`NavigationStack`, `TabView`, sheets) и роутинга.

### 1. Первый запуск

**Onboarding (3 шага)** — знакомство с приложением, без возможности пропуска:

- [OnB_01_Welcome.png](docs/app-design/screens/OnB_01_Welcome.png) — приветствие, ценностное предложение
- [OnB_02_Log.png](docs/app-design/screens/OnB_02_Log.png) — как логировать подходы
- [OnB_03_Analyze.png](docs/app-design/screens/OnB_03_Analyze.png) — как читать прогресс

**Profile Setup** → [Profile Setup.png](docs/app-design/screens/Profile%20Setup.png):

- Имя, вес тела, выбор маскота, разрешения (уведомления / хаптика)
- Создаётся `UserProfile` в SwiftData
- Флаг «онбординг пройден» сохраняется, при следующих запусках не показываем

### 2. Основная навигация (TabView, 4 вкладки)

#### Таб 1: Dashboard → [Dashboard.png](docs/app-design/screens/Dashboard.png)

Главный хаб действий:

- Горизонтальный календарь недели
- Виджет «Следующая тренировка»
- Быстрая статистика (тоннаж, кол-во тренировок, кольцо прогресса)
- **«Быстрый старт»** → запускает `WorkoutSession` без плана → **Active Workout**
- **«Создать тренировку»** → открывает **Workout Builder** (создание нового `WorkoutPlan`)
- **Тап по шаблону тренировки** → запускает сессию по плану → **Active Workout**

#### Таб 2: Exercise Library → [Exercise library.png](docs/app-design/screens/Exercise%20library.png)

Каталог упражнений:

- Поиск + фильтр-чипсы по `MuscleGroup`
- **Тап по карточке** → **Exercise Detail** (Sheet): описание, техника, ошибки, история `PersonalRecord`, анимация маскота

#### Таб 3: Progress & Analytics → [Progress and analytics.png](docs/app-design/screens/Progress%20and%20analytics.png)

История и аналитика **завершённых сессий** (`WorkoutSession` с `finishedAt != nil`):

- График тоннажа (`SwiftUI.Charts`)
- Список пройденных сессий (хронологически)
- **Тап по сессии** → **Session Detail (превью)** — read-only: упражнения, подходы, вес × повторы, итоговый тоннаж, длительность

#### Таб 4: Settings & Profile → [Settings and profile.png](docs/app-design/screens/Settings%20and%20profile.png)

- Профиль, смена маскота, настройки уведомлений / звука / хаптики
- Экспорт CSV истории тренировок

### 3. Вспомогательные экраны

**Workout Builder** → [Workout builder.png](docs/app-design/screens/Workout%20builder.png)

- Вход: только с Dashboard
- Drag & Drop список `PlanExercise`, настройка `targetSets` и `restDuration`
- Сохранение → новый `WorkoutPlan`, возврат на Dashboard

**Active Workout** → [Active workout.png](docs/app-design/screens/Active%20workout.png)

- Вход: с Dashboard (Быстрый старт или тап по шаблону)
- Ввод веса / повторов, таймер отдыха, нижняя панель таймеров, маскот сверху
- При закрытии приложения сессия сохраняется (`finishedAt == nil`)

### 4. Восстановление активной сессии

При запуске приложения (после онбординга) проверяется наличие `WorkoutSession` с `finishedAt == nil`:

- Если есть → сразу открываем **Active Workout** поверх Dashboard
- Если нет → стандартный Dashboard

### Карта переходов

```
[Onboarding] → [Profile Setup] → [TabView]
                                    ├── Dashboard ──┬→ Workout Builder
                                    │               ├→ Active Workout (быстрый старт)
                                    │               └→ Active Workout (по плану)
                                    ├── Exercise Library → Exercise Detail (Sheet)
                                    ├── Progress → Session Detail (превью)
                                    └── Settings
```

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
