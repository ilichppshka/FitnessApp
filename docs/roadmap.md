# Development Roadmap

Поэтапный план реализации. Каждая фаза заканчивается состоянием, которое можно собрать и запустить.

## Фаза 0 · Bootstrap (1–2 дня)

Цель: проект компилируется, есть скелет, работает Dark theme.

- [x] Установить XcodeGen, SwiftLint
- [x] Создать `project.yml` (см. [project-structure.md](project-structure.md#4-xcodegen-projectyml))
- [x] Создать структуру каталогов `FitnesApp/{App,Core,Data,Domain,Features,DesignSystem,Resources,Tests}`
- [x] `FitnesAppApp.swift` с пустой `RootView`, `.preferredColorScheme(.dark)`
- [x] Подключить шрифты Space Grotesk + SF Pro
- [x] `DesignSystem/Tokens/Colors.swift` — палитра Kinetic Laboratory
- [x] `.swiftlint.yml`, базовые правила
- [x] CI-чек: `xcodegen generate && xcodebuild -scheme FitnesApp build`

**Критерий готовности:** приложение запускается на симуляторе, видна тёмная тема и кастомный шрифт.

---

## Фаза 1 · Data Layer (2–3 дня)

Цель: SwiftData-модели, репозитории, сидинг каталога.

- [ ] Реализовать все 8 `@Model`-классов из [data-layer.md](data-layer.md#2-модели)
- [ ] `ModelContainer.makeProduction()` + `makePreview()`
- [ ] `SchemaV1` + пустой `AppMigrationPlan`
- [ ] DTO для всех моделей (`Sendable`)
- [ ] 4 репозитория: `Exercise`, `Workout`, `Session`, `User`
- [ ] `DataSeeder` + `ExerciseSeed.makeAll(...)` (30+ упражнений)
- [ ] Юнит-тесты репозиториев на in-memory контейнере

**Критерий готовности:** при первом запуске БД заполняется упражнениями, репозитории возвращают данные, тесты зелёные.

---

## Фаза 2 · Domain Layer (2 дня)

Цель: бизнес-логика поверх репозиториев.

- [ ] `WorkoutService` (startSession, logSet, finishSession, resumeActiveSession)
- [ ] `AnalyticsService` (weeklyTonnage, monthlyTonnage, sessionHistory)
- [ ] `TimerService` (workout + rest timers)
- [ ] `NotificationService` (UNUserNotifications)
- [ ] `CSVExporter` (actor)
- [ ] `TonnageCalculator`, `PersonalRecordCalculator`
- [ ] `AppError` enum
- [ ] Юнит-тесты сервисов с моками репозиториев

**Критерий готовности:** все сервисы покрыты тестами, нет warnings Swift 6 Concurrency.

---

## Фаза 3 · Design System Components (2 дня)

Цель: переиспользуемые компоненты UI.

- [ ] `KineticButton` (primary/secondary, Neon Glow)
- [ ] `PerformanceCard` (surface-container-high, rounded `md`)
- [ ] `FloatingNavPill` (glassmorphism таб-бар)
- [ ] `GhostInputField`
- [ ] `NeonGlowModifier` (drop-shadow с primary)
- [ ] `Theme.swift` корневой modifier
- [ ] Каталог компонентов в `#Preview`

**Критерий готовности:** есть «storybook» previews для всех компонентов, визуально соответствуют design-system.md.

---

## Фаза 4 · Dashboard (1–2 дня)

- [ ] `DashboardViewModel` + загрузка статистики недели
- [ ] `WeekCalendarStrip`
- [ ] `NextWorkoutCard`
- [ ] `WeeklyStatsRing`
- [ ] Интеграция с `AppRouter` (Quick Start → fullScreenCover)
- [ ] `#Preview` с фикстурами

**Критерий готовности:** на главном экране видна реальная статистика, можно стартовать пустую сессию.

---

## Фаза 5 · Exercise Library (1–2 дня)

- [ ] `ExerciseLibraryViewModel` с debounced search
- [ ] `MuscleGroupChip` фильтры
- [ ] `ExerciseDetailSheet` с 3 секциями описания
- [ ] История `PersonalRecord` в детальном экране
- [ ] Lottie/.mov плеер заглушкой (пока без реальных ассетов)

**Критерий готовности:** список фильтруется и ищется, открывается Sheet с деталями.

---

## Фаза 6 · Active Workout (3–4 дня)

Самый сложный экран. Делать в последнюю очередь.

- [ ] `ActiveWorkoutViewModel` с восстановлением активной сессии
- [ ] `MascotStage` (заглушка, реальные ассеты — Фаза 9)
- [ ] `SetInputPanel` с цифровой клавиатурой и большими полями
- [ ] `RestTimerBar` с +15 сек
- [ ] Haptic feedback на «Выполнено» и окончание таймера
- [ ] Локальное уведомление об окончании отдыха
- [ ] Сохранение `WorkoutSet` сразу в БД, не в памяти
- [ ] `fullScreenCover` поверх таб-бара
- [ ] Bootstrap: `WorkoutService.resumeActiveSession()` при старте → автопереход

**Критерий готовности:** полный цикл — старт → 3 упражнения × 3 сета → финиш. После kill-а приложения активная сессия восстанавливается.

---

## Фаза 7 · Workout Builder (1–2 дня)

- [ ] `WorkoutBuilderViewModel` (CRUD + reorder)
- [ ] `List` с `.onMove` для drag&drop
- [ ] Stepper для `targetSets`, поле для `restDuration`
- [ ] Sheet «Добавить упражнение» (упрощённая Library)
- [ ] Сохранение через `WorkoutRepository.upsert`

**Критерий готовности:** можно создать план, добавить упражнения, переупорядочить, сохранить, запустить с Dashboard.

---

## Фаза 8 · Progress (1 день)

- [ ] `ProgressViewModel` с диапазонами week/month/3m
- [ ] `TonnageChart` через Swift Charts
- [ ] `SessionHistoryRow` + `SessionDetailView`
- [ ] Push на детали сессии

**Критерий готовности:** график тоннажа отображает реальные данные, можно открыть детали любой сессии.

---

## Фаза 9 · Mascot Integration (2 дня)

- [ ] Lottie SPM dependency
- [ ] Помещение JSON-анимаций в `Resources/Lottie/`
- [ ] `MascotStage` с состояниями `idle/active/complete`
- [ ] Маппинг `Exercise.animationAssetName` → файл
- [ ] `selectedMascotId` через `UserProfile`
- [ ] Плавное «схлопывание» при скролле (matchedGeometryEffect)

**Критерий готовности:** на ActiveWorkout маскот зациклен и реагирует на состояние; на ExerciseDetail показывает технику упражнения.

---

## Фаза 10 · Settings + Export (1 день)

- [ ] `SettingsViewModel`
- [ ] Form с профилем, маскотом, уведомлениями
- [ ] `MascotPicker` карусель
- [ ] Экспорт CSV → `ShareLink(item: url)`
- [ ] Запрос разрешений `UserNotifications` при первом включении

**Критерий готовности:** можно поменять имя/вес, выбрать маскота, экспортировать CSV в Files.app.

---

## Фаза 11 · Polish & Performance (2–3 дня)

- [ ] Анимации SF Symbols 6 для таб-бара
- [ ] Haptic Feedback во всех нужных точках
- [ ] Empty states для всех списков
- [ ] Локализация ru + en через xcstrings
- [ ] Dynamic Type до AX1
- [ ] Accessibility labels для всех интерактивных элементов
- [ ] Snapshot-тесты ключевых экранов
- [ ] Профайлинг через Instruments (TimerService, графики)

**Критерий готовности:** все экраны полированы, snapshot-тесты зелёные, нет видимых рывков на 60fps.

---

## Сводная диаграмма зависимостей

```
Bootstrap ─► Data ─► Domain ─► Components ─┬─► Dashboard
                                            ├─► Library ──► Active Workout
                                            ├─► Builder
                                            ├─► Progress
                                            └─► Settings
                                                │
                                          Mascot Integration ─► Polish
```

Можно вести Library, Builder, Progress, Settings параллельно после Фазы 3.
Active Workout зависит от Library (нужен список упражнений для добавления сетов вне плана).

## Definition of Done для каждой фазы

- [ ] Код компилируется без warnings под Swift 6 Strict Concurrency
- [ ] SwiftLint проходит без ошибок
- [ ] Юнит-тесты добавлены/обновлены
- [ ] `#Preview` работает с in-memory контейнером
- [ ] Ручной smoke test на симуляторе iPhone 16 / iOS 18
- [ ] Документация в [docs/](.) обновлена при изменении контракта
