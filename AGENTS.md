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
| **Analytics**        | Тоннаж, история, графики, серии (streak), новые PR, дельты периодов |
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
    var isFavorite: Bool             // ⭐ избранное (тоггл в Exercise Detail)
    @Relationship(deleteRule: .cascade)
    var personalRecords: [PersonalRecord]
}
```

> `Est. 1RM` и `Attempts` в Exercise Detail — производные от `personalRecords`, вычисляются в `AnalyticsService` (не хранятся).

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
enum WeightUnit: String, Codable { case kg, lb }   // переключается в Settings

@Model class UserProfile {
    var id: UUID
    var name: String
    var bodyWeight: Double                // для упражнений с собственным весом
    var weightUnit: WeightUnit            // kg / lb — переключатель в Settings
    var selectedMascotId: String          // пока 2 маскота: "duck" (утка) и "baklazha"
    var defaultRestDuration: TimeInterval // дефолтный таймер отдыха (Settings)
    var autoStartRestTimer: Bool          // авто-старт отдыха после "Complete Set"
    var restSoundEnabled: Bool            // Rest timer alerts (локальные уведомления)
    var restHapticEnabled: Bool           // Haptic feedback
    // Авторизация пока НЕ реализуется. План — вход по Telegram ID (OAuth),
    // тогда сюда добавится telegramUserId / email. См. User Flow · Settings.
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

Полный пользовательский флоу по финальному дизайну **KINETIC** (Kinetic Laboratory). Детальный поэкранный разбор и карта переходов — в [docs/userflow.md](docs/userflow.md); исходные макеты — [docs/app-design/design-claude-code/](docs/app-design/design-claude-code/). Дизайн: **Dark Mode Only**, акцент lime `#d3f670`, шрифты Space Grotesk + системный SF (SF Pro / SF Mono), плавающий (floating pill) таб-бар.

### 1. Первый запуск

**Onboarding (3 шага)** — приветствие. **Есть кнопка `Skip`** (можно пропустить к Profile Setup):

1. **Welcome** — «Train like a laboratory», ценностное предложение.
2. **Log** — как логировать подходы (one-tap, авто-таймеры отдыха, PR-алерты).
3. **Analyze** — как читать прогресс (тоннаж, серии, рекорды).

**Profile Setup** (после онбординга):

- Поля: **имя**, **вес тела** (с переключателем `kg / lb`), **выбор маскота**.
- **Разрешения:** на этом экране показываем **только системный запрос на отправку уведомлений** (push permission). Тумблеры звука / хаптики / алертов — в **Settings**.
- Создаётся `UserProfile`; флаг «онбординг пройден» сохраняется, при следующих запусках экран не показываем.

### 2. Основная навигация (TabView, 4 таба)

Табы: **Home (Dashboard)**, **Library**, **Progress**, **Profile (Settings)**. Запуск тренировки (`Train`) и конструктор — **не табы**, а полноэкранные экраны, открываемые из Home.

#### Таб 1: Home / Dashboard

Главный хаб действий:

- Горизонтальный календарь недели (состояния дней: done / today / planned / rest).
- Hero-виджет «Следующая тренировка» с CTA **`Start Workout`** → сессия по плану → **Active Workout**.
- Быстрая статистика недели (тоннаж, кольцо прогресса сессий, дельта vs прошлая неделя).
- **`Quick Start`** → `WorkoutSession` без плана → **Active Workout**.
- Виджет «Latest PR».
- Вход в **Workout Builder** (создание / редактирование `WorkoutPlan`).

#### Таб 2: Exercise Library

Каталог упражнений:

- Поиск + фильтр-чипсы по `MuscleGroup`, блоки «Exercise of the Day» и «Recent».
- **Тап по карточке** → **Exercise Detail** (Sheet).

#### Таб 3: Progress & Analytics

История и аналитика **завершённых сессий** (`WorkoutSession` с `finishedAt != nil`):

- Range-табы: **Week / Month / 3M / Year / All**.
- Hero-метрика тоннажа + дельта vs предыдущий период.
- График тоннажа (`SwiftUI.Charts`).
- Stats grid: **Sessions · Time · New PRs · Streak** (с дельтами к прошлому периоду).
- Список пройденных сессий → **Session Detail** (read-only: упражнения, подходы, вес × повторы, тоннаж, длительность).

#### Таб 4: Settings & Profile

- Профиль (имя, вес, рост, уровень), смена маскота.
- **TRAINING:** дефолтный таймер отдыха, **единица веса `kg / lb`**, авто-старт таймера отдыха.
- **NOTIFICATIONS & FEEDBACK:** алерты таймера отдыха, хаптика.
- **DATA:** экспорт CSV, (Apple Health — позже), очистка истории.
- **ACCOUNT:** авторизация пока **не реализуется**. План — вход через **Telegram ID (OAuth)**.

### 3. Вспомогательные (полноэкранные) экраны

**Workout Builder** — вход из Home; Drag & Drop список `PlanExercise`, настройка `targetSets` и `restDuration`, авто-сохранение черновика; сохранение → `WorkoutPlan`, возврат на Home.

**Active Workout** — fullscreen-модал из Home (быстрый старт или по плану):

- Маскот сверху, блок ввода Вес / Повторы, кнопка **`Complete Set`**, общий таймер сессии.
- Таймер отдыха с кнопками **`−15s` / `+15s` / `Skip`**.
- **Подсказка прогрессии:** рекомендуемый вес следующего подхода + ссылка на прошлый результат (`Last set: 70kg × 10`).
- При закрытии приложения сессия сохраняется (`finishedAt == nil`).

**Exercise Detail (Sheet над Library)** — описание, техника, ошибки, маскот-демо; **вкладки `Technique / PRs / History`**; карточка PR с **Est. 1RM** и **Attempts**; **избранное (⭐)**; **share / export**; кнопка `Add to Workout`.

### 4. Восстановление активной сессии

При запуске (после онбординга) проверяется наличие `WorkoutSession` с `finishedAt == nil`:

- Если есть → сразу открываем **Active Workout** поверх Home.
- Если нет → стандартный Home.

### Карта переходов

```
[Onboarding ×3 · Skip] → [Profile Setup] → [TabView · 4 таба]
                                              ├── Home ──┬→ Active Workout (быстрый старт / по плану)
                                              │          └→ Workout Builder
                                              ├── Library → Exercise Detail (Sheet)
                                              ├── Progress → Session Detail (read-only)
                                              └── Profile / Settings
```

---

## 1. Архитектор системы (System Architect Agent)

**Цель:** Проектирование масштабируемой структуры приложения и схемы данных.

- **Зоны ответственности:**
  - Реализация SwiftData-моделей из раздела «Ключевые сущности».
  - Настройка Swift 6 Strict Concurrency и безопасности данных.
  - Реализация `ExerciseRepository`, `WorkoutRepository`, `SessionRepository`.
  - Реализация `WorkoutService` (startSession / logSet / finishSession).
  - Реализация `AnalyticsService`: тоннаж за период с дельтой к предыдущему, фильтрация по диапазону (Week/Month/3M/Year/All), серия (streak), число новых PR, `Est. 1RM` и `Attempts` (производные от `PersonalRecord`).
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
  - **Onboarding:** 3 слайда + кнопка `Skip`; индикатор страниц.
  - **Dashboard:** горизонтальный календарь-скролл недели (done/today/planned/rest), hero «Следующая тренировка» с CTA `Start Workout`, блок быстрой статистики (тоннаж, кольцо прогресса), `Quick Start`, виджет Latest PR.
  - **Exercise Library:** поиск + фильтр-чипсы по `MuscleGroup`, «Exercise of the Day», «Recent», список карточек.
  - **Exercise Detail (Sheet):** вкладки `Technique / PRs / History`, карточка PR с `Est. 1RM` и `Attempts`, избранное (⭐), share/export, `Add to Workout`.
  - **Workout Builder:** Drag & Drop список `PlanExercise`, настройка `targetSets` и `restDuration`, авто-сохранение черновика.
  - **Active Workout:** блок ввода (Вес + Повторения) с подсказкой прогрессии, кнопка `Complete Set`, нижняя панель таймера отдыха (`−15s / +15s / Skip`).
  - **Progress:** range-табы (Week/Month/3M/Year/All), hero-метрика с дельтой, график тоннажа (`SwiftUI.Charts`), stats grid (Sessions/Time/New PRs/Streak), список сессий.
  - **Settings:** профиль, выбор маскота, единица веса `kg / lb`, дефолтный таймер отдыха, авто-старт отдыха, уведомления/хаптика, экспорт CSV, секция Account (Telegram OAuth — позже).
- **Ключевые инструкции:**
  - **Dark Mode Only**; токены Kinetic Laboratory (lime `#d3f670`, Space Grotesk + системный SF) — см. [docs/userflow.md](docs/userflow.md) § Design System.
  - Плавающий (floating pill) таб-бар, 4 таба; Workout Builder / Active Workout — полноэкранные (не табы).
  - Крупные кнопки и поля ввода — управление одной рукой на экране Active Workout.
  - SF Symbols 6 с анимацией для таб-бара.
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
  - **Маскотов пока 2:** «утка» (`duck`) и «бакляха» (`baklazha`). Сами ассеты будут сгенерированы позже — пока используем плейсхолдеры, но архитектуру выбора маскота закладываем на расширяемый список.
  - Маскот занимает верхнюю треть экрана Active Workout.
  - На экране Exercise Library — маскот в Sheet демонстрирует технику конкретного упражнения.
  - Анимация зациклена и плавна, оптимизирована по CPU/GPU.

## 4. Инженер по логике тренировок (Logic & Tracking Agent)

**Цель:** Управление состоянием тренировки, таймерами и вычислениями.

- **Зоны ответственности:**
  - `ActiveWorkoutViewModel`: хранит текущую `WorkoutSession`, текущий `PlanExercise`, номер сета.
  - Общий таймер тренировки (`startedAt` → now).
  - Таймер отдыха: запускается после `Complete Set` (или авто-старт по `UserProfile.autoStartRestTimer`), поддерживает `−15s / +15s / Skip`.
  - **Логика прогрессии:** рекомендация веса следующего подхода и подтяжка прошлого результата (`Last set: …`) на основе истории `WorkoutSet` / `PersonalRecord`.
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
