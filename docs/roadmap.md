# Development Roadmap

Поэтапный план реализации. Каждая фаза заканчивается состоянием, которое можно собрать и запустить.

## Фаза 0 · Bootstrap (1–2 дня)

Цель: проект компилируется, есть скелет, работает Dark theme.

- [x] Установить XcodeGen, SwiftLint
- [x] Создать `project.yml` (XcodeGen — см. [AGENTS.md](../AGENTS.md))
- [x] Создать структуру каталогов `FitnesApp/{App,Core,Data,Domain,Features,DesignSystem,Resources,Tests}`
- [x] `FitnesAppApp.swift` с пустой `RootView`, `.preferredColorScheme(.dark)`
- [x] Подключить шрифт Space Grotesk (бандлим; SF Pro / SF Mono — системные)
- [x] `DesignSystem/Tokens/Colors.swift` — палитра Kinetic Laboratory
- [x] `.swiftlint.yml`, базовые правила
- [x] CI-чек: `xcodegen generate && xcodebuild -scheme FitnesApp build`

**Критерий готовности:** приложение запускается на симуляторе, видна тёмная тема и кастомный шрифт.

---

## Фаза 1 · Data Layer (3–4 дня)

Цель: SwiftData-схема по [models.md](models.md) (10 моделей + 4 enum), репозитории, сидинг каталога с мышечными связями.

> Схема пересмотрена относительно первоначального наброска из 8 моделей: добавлены join `ExerciseMuscle` (роль мышцы), `PlanSet` (план по сетам), enum'ы и новые поля. Канон — [models.md](models.md).

- [x] 4 enum (`Codable`): `WeightUnit`, `Difficulty`, `Equipment`, `MuscleRole`
- [x] 10 `@Model`-классов из [models.md · §2](models.md#2-модели): `UserProfile`, `MuscleGroup`, `ExerciseMuscle`, `Exercise`, `PersonalRecord`, `WorkoutPlan`, `PlanExercise`, `PlanSet`, `WorkoutSession`, `WorkoutSet`
- [x] Связи и delete-rules по таблице из [models.md · §3](models.md#3-связи-и-правила-удаления): cascade-владение, nullify-ссылки, явные `inverse`
- [x] Derived-свойства: `Exercise.primary/secondaryMuscles`, `WorkoutPlan.totalSets/targetMuscleGroups`, `PlanExercise.targetSets`, `WorkoutSession.isActive/duration/containsPR`
- [x] `ModelContainer.makeProduction()` + `makePreview()` (in-memory), `Schema` из 10 моделей
- [x] `SchemaV1` (10 моделей) + пустой `AppMigrationPlan`
- [x] DTO (`Sendable`): `ExerciseDTO` (+`difficulty`/`equipment`/`isFavorite`/мышцы), `WorkoutPlanDTO`/`PlanExerciseDTO`/`PlanSetDTO`, `WorkoutSessionDTO` (+`title`/`containsPR`), `WorkoutSetDTO` (+`isPersonalRecord`)
- [x] 4 репозитория: `ExerciseRepository` (search по `muscleLinks`, favorites-тоггл), `WorkoutRepository` (CRUD планов, `reorder`, `planSets`, draft), `SessionRepository` (active/create/addSet/finish/history), `UserRepository` (current/update)
- [x] `DataSeeder` + `MuscleGroupSeed` (Chest/Back/Legs/Shoulders/Arms/Core) + `ExerciseSeed.all` — 30+ упражнений с `ExerciseMuscle` (primary/secondary), `difficulty`, `equipment`
- [x] Дефолтный `UserProfile` при первом запуске (`weightUnit = .kg`, маскот `"duck"`)
- [x] Юнит-тесты репозиториев и сидинга на in-memory контейнере

**Критерий готовности:** при первом запуске БД заполняется упражнениями с мышечными связями, сложностью и оборудованием; репозитории фильтруют по группе мышц и отдают favorites; план с `PlanSet` сохраняется и переупорядочивается; сессия создаётся/финализируется с корректным `totalTonnage`; тесты зелёные; нет warnings Swift 6 Concurrency.

---

## Фаза 2 · Domain Layer (3 дня)

Цель: сервисы бизнес-логики поверх репозиториев. Канон — [services-and-repository.md](services-and-repository.md).

> Сервисы оркеструют, репозитории хранят (см. [services-and-repository.md · §0](services-and-repository.md#0-принципы-доменного-слоя)). Репозитории заведены в Фазе 1; здесь — доменная логика и недостающие query-методы под сервисы.

- [x] Расширить репозитории методами под сервисы ([§2](services-and-repository.md#2-репозитории)): `ExerciseRepository` (`muscleGroups`, `exerciseOfTheDay`, `recent`, `personalRecords`), `WorkoutRepository` (`scheduled(weekday:)`, `publish`), `SessionRepository` (`lastSet`, `clearHistory`)
- [x] `WorkoutService` ([§3.1](services-and-repository.md#31-workoutservice--жизненный-цикл-сессии)): `startSession(planID:)`, `resumeActiveSession`, `logSet` (tonnage + детект PR по Epley → `isPersonalRecord` + `PersonalRecord`), `finishSession`, `discardSession`
- [x] `ProgressionService` ([§3.2](services-and-repository.md#32-progressionservice--рекомендация-следующего-подхода)): `suggestion(exerciseID:planExercise:)` → рекомендация веса + `lastSet`
- [x] `RestTimerService` ([§3.3](services-and-repository.md#33-resttimerservice--таймер-отдыха)): `@Observable @MainActor`, `start`/`adjust(±15)`/`skip`/`pause`/`resume`, авто-старт по `autoStartRestTimer` (таймер сессии `startedAt → now` — на уровне `ActiveWorkoutVM`)
- [x] `NotificationService` ([§3.4](services-and-repository.md#34-notificationservice--локальные-уведомления)): `requestAuthorization`, `scheduleRestEnd`, `cancelRestEnd` (без Live Activities)
- [x] `HapticsService` ([§3.5](services-and-repository.md#35-hapticsservice--тактильный-фидбек)): `play(.setLogged/.restDone/.personalRecord)` с учётом `restHapticEnabled`
- [x] `AnalyticsService` ([§3.6](services-and-repository.md#36-analyticsservice--метрики-и-агрегаты)): `DateRange`/`Metric`, `totalTonnage`/`tonnageSeries`/`sessionsCount`/`totalTime`/`newPRsCount`/`currentStreak` (Progress), `estimatedOneRepMax`/`attempts` (Detail), `weekStates`/`weeklyVolume`/`sessionRing`/`latestPR` (Dashboard), `estimatedDuration` (Plan)
- [x] `CSVExporter` ([§3.7](services-and-repository.md#37-csvexporter--экспорт-истории)): `exportHistory()` на фоновом контексте → `URL`
- [x] `AppServices` ([§4](services-and-repository.md#4-сквозные-вопросы)): сборка графа (репозитории из `ModelContext`, сервисы из репозиториев), инжект через `Environment`
- [x] Доменные ошибки: `WorkoutError`, `DataError`
- [x] Юнит-тесты сервисов с мок-репозиториями: детект PR (`WorkoutService`), дельты/streak (`AnalyticsService`), эвристика (`ProgressionService`)

**Критерий готовности:** `logSet` считает tonnage и поднимает PR-флаг/`PersonalRecord`; `AnalyticsService` отдаёт метрики с дельтами и streak по диапазонам; `RestTimerService` корректно отрабатывает `±15/Skip` и шлёт локальное уведомление; все сервисы покрыты тестами; нет warnings Swift 6 Concurrency.

---

## Фаза 3 · Design System — токены и примитивы (2–3 дня)

Цель: токены и переиспользуемые **примитивы** из [ui-components.md](ui-components.md) (§1–2.1). Композиты конкретных экранов делаются в фазах 4–10.

**Токены** (заложены вместе с Bootstrap; используются Onboarding'ом):
- [x] `Color.App` — палитра Kinetic Laboratory (4 этажа `surface` + lime + текст + danger), [ui-components.md §1.1](ui-components.md#11-цвета)
- [x] `Font.App` — Space Grotesk (display/цифры) + системный SF (UI) + SF Mono (тех-теги), [§1.2](ui-components.md#12-типографика)
- [x] `Spacing` · `Radii`, [§1.3–1.4](ui-components.md#13-отступы-и-раскладка)
- [x] `Theme` (`kineticTheme()`: `.preferredColorScheme(.dark)`) + `NeonGlowModifier` (`.neonGlow()`)

**Примитивы** (отмеченные — уже есть под Onboarding):
- [x] `KineticButton` (PrimaryButton: lime, `onPrimary`, glow, trailing-иконка)
- [x] `SectionLabel` (UPPER eyebrow)
- [x] `ProgressDots` (пейджер онбординга)
- [ ] `IconButton`, чипсы (`FilterChip` / `MuscleTag` / `EquipmentTag` / `DeltaBadge` / `CounterChip` / `PRBadge`), `GlassPill`
- [ ] `StatusDot`, `KineticToggle`, `StepperButton`, `ProgressRing`, `DifficultyBars`
- [ ] `SearchField`, `SetField`, `GhostInputField`, `Avatar`, `StatNumber`, `MonoTag`, `FrameTag`, `ChevronRight`
- [ ] `ComponentCatalog` (storybook под `#if DEBUG`) со всеми состояниями

**Критерий готовности:** примитивы покрыты `#Preview` со всеми состояниями и собраны в `ComponentCatalog`; соответствуют [ui-components.md](ui-components.md).

---

## Фаза 3.5 · Onboarding + Profile Setup (частично готово)

Точка входа для нового пользователя: 3-шаговый онбординг (**готов**) и первичное создание `UserProfile` через Profile Setup (**осталось**). Экраны — [userflow.md §2](userflow.md#2-первый-запуск); компоненты — [ui-components.md](ui-components.md).

**Onboarding — готово:**
- [x] `OnboardingFlowView` + `OnboardingFlowViewModel`
- [x] `OnboardingPageScaffold` (общий контейнер: `ProgressDots` + `Skip` + CTA)
- [x] 3 страницы: `OnboardingWelcomePage` (с `bolt.fill` заглушкой), `OnboardingLogPage`, `OnboardingAnalyzePage`
- [x] `@AppStorage("onboardingCompleted")` интеграция в `RootView`
- [x] Локализация ключей `onboarding.*` (en + ru)
- [x] `#Preview` для страниц онбординга

**Profile Setup — осталось:**
- [ ] `ProfileSetupView` + `ProfileSetupViewModel` → `UserRepository.update` создаёт `UserProfile`
- [ ] Поля: имя (`GhostInputField`), вес тела с переключателем `kg / lb` (`SetField` + unit-toggle), `MascotPickerGrid`
- [ ] `MascotPickerGrid` + `MascotOption` — **2 маскота** (`duck`, `baklazha`), SF Symbol заглушки (набор расширяемый)
- [ ] Системный prompt `UNUserNotifications` через `NotificationService.requestAuthorization()` в `.task` у `ProfileSetupView` (одноразово, флаг `@AppStorage("notificationPromptShown")`)
- [ ] Локализация ключей `profileSetup.*` (en + ru)
- [ ] Юнит-тест `ProfileSetupViewModelTests.testSaveCreatesUserProfile`
- [ ] `#Preview` для Profile Setup
- [ ] Заменить `bolt.fill` на бренд-SVG из `Resources/Assets.xcassets` (когда пользователь его положит)

**Критерий готовности:** при первом запуске 3 страницы онбординга → Profile Setup → после сохранения создан `UserProfile` и открыт Dashboard; при повторном запуске онбординг не показывается.

---

## Фаза 4 · Dashboard (1–2 дня)

Экран — [userflow.md §3](userflow.md#3-таб-1--home--dashboard); компоненты — [ui-components.md](ui-components.md); данные — `AnalyticsService` / `WorkoutRepository` / `WorkoutService`.

- [ ] `DashboardViewModel` (через `AnalyticsService`: `weekStates`, `weeklyVolume`, `sessionRing`, `latestPR`; `WorkoutRepository.scheduled`)
- [ ] `DashboardTopBar` (eyebrow-дата + greeting + `Avatar` с notif-dot)
- [ ] `WeekStrip` + `DayCell` (состояния `done` / `today` / `planned` / `rest`)
- [ ] `NextWorkoutCard` (hero: обложка + `GlassPill` + `StatRow` + `MuscleTag` + CTA `Start Workout`)
- [ ] `QuickStatsCard` (`ProgressRing` 3/5 + `TOTAL VOLUME` + `DeltaBadge`)
- [ ] `QuickActionCard` ×2 (`Quick Start` → пустая сессия; `Latest PR`)
- [ ] `FloatingNavBar` — **4 таба** (Home/Library/Progress/Profile), общий для табов; первый раз собирается здесь
- [ ] Роутинг: `Start Workout` / `Quick Start` / тап по плану → `fullScreenCover` Active Workout; вход в Builder → push/fullscreen
- [ ] `#Preview` с фикстурами

**Критерий готовности:** на главном экране реальная недельная статистика и план дня; `Quick Start` открывает Active Workout.

---

## Фаза 5 · Exercise Library + Exercise Detail (2 дня)

Экраны — [userflow.md §4–5](userflow.md#4-таб-2--library--exercise-library); данные — `ExerciseRepository`, `AnalyticsService`.

**Library:**
- [ ] `LibraryViewModel` с debounced-поиском (`ExerciseRepository.search`, `muscleGroups`, `exerciseOfTheDay`, `recent`)
- [ ] `SearchField` + `FilterChipsRow` (чипсы по `MuscleGroup`)
- [ ] `FeaturedExerciseCard` («Exercise of the Day») + `SectionHeaderRow`
- [ ] `ExerciseRow` (thumb + `EquipmentTag` + мышцы + `DifficultyBars` + `PRBadge` + `+`)

**Exercise Detail (sheet):**
- [ ] `ExerciseDetailSheet` + `ExerciseDetailViewModel`
- [ ] Вкладки `Technique / PRs / History` (сегмент), `MuscleTag` (primary/secondary)
- [ ] PR-карточка: `Est. 1RM` + `Attempts` (`AnalyticsService.estimatedOneRepMax` / `attempts`)
- [ ] ⭐ избранное (`ExerciseRepository.setFavorite`), share, `Add to Workout`
- [ ] `MascotCanvas`-демо техники (заглушка; реальная анимация — Фаза 9)

**Критерий готовности:** каталог фильтруется/ищется; открывается Detail с техникой, PR-метриками и тогглом избранного.

---

## Фаза 6 · Active Workout (3–4 дня)

Самый сложный экран — [userflow.md §7](userflow.md#7-active-workout-fullscreen-модал). Логика — `WorkoutService`, `ProgressionService`, `RestTimerService`, `NotificationService`, `HapticsService`.

- [ ] `ActiveWorkoutViewModel` (старт/лог/финиш через `WorkoutService`; `resumeActiveSession`; таймер сессии `startedAt → now`)
- [ ] `MascotCanvas` (заглушка; реальные ассеты — Фаза 9)
- [ ] `ActiveExerciseInfo` (`EXERCISE n OF m` + `ProgressDots` + `Set x of y · Last set: …`)
- [ ] `InputBlock` ×2 (Weight/Reps: `StepperButton` + `DeltaBadge` подсказки)
- [ ] `ProgressionService` — рекомендация веса (`↑ +5kg`) + `lastSet`
- [ ] `CompleteSetButton` (лог сета + shimmer + haptic)
- [ ] `RestTimerBar` (`RestTimerService`: `−15s / +15s / Skip` + прогресс; авто-старт по `autoStartRestTimer`)
- [ ] Локальное уведомление об окончании отдыха (`NotificationService`)
- [ ] `WorkoutSet` сохраняется сразу в SwiftData (не в памяти)
- [ ] `fullScreenCover` поверх таб-бара; на cold start `WorkoutService.resumeActiveSession()` → автопереход

**Критерий готовности:** полный цикл старт → сеты → финиш с верным `totalTonnage`; после kill-а приложения активная сессия восстанавливается.

---

## Фаза 7 · Workout Builder (1–2 дня)

Экран — [userflow.md §6](userflow.md#6-workout-builder-полноразмерный-из-home); данные — `WorkoutRepository`.

- [ ] `WorkoutBuilderViewModel` (`createDraft`, `addExercise`, `reorder`, `setPlanSets`, `setRest`, `publish`)
- [ ] `BuilderSummaryCard` (`EXERCISES / EST. TIME / TOTAL SETS`)
- [ ] `BuilderExerciseCard` (collapsed/expanded) + `SetEditorRow` + `AddSetButton` + `RestPill`
- [ ] Drag&drop через `List` / `.onMove` → пересчёт `PlanExercise.order`
- [ ] `AddExerciseButton` → sheet выбора упражнения (упрощённая Library)
- [ ] Авто-сохранение черновика (`isDraft`, `updatedAt` → «Auto-saved»)
- [ ] `BottomActionDock` с CTA `Save Plan` (`publish`)

**Критерий готовности:** план создаётся с упражнениями и `PlanSet`, переупорядочивается, сохраняется и запускается с Dashboard.

---

## Фаза 8 · Progress + Session Detail (1–2 дня)

Экраны — [userflow.md §8](userflow.md#8-таб-3--progress--analytics); метрики — `AnalyticsService`, история — `SessionRepository`.

- [ ] `ProgressViewModel` (range-метрики `AnalyticsService` по `DateRange`)
- [ ] `RangeTabs` (`Week / Month / 3M / Year / All`)
- [ ] `HeroMetric` (тоннаж за период + `DeltaBadge` vs предыдущий)
- [ ] `VolumeChart` через **Swift Charts** (area + glow last-point)
- [ ] `StatsGrid` + `StatTile` ×4 (`Sessions / Time / New PRs / Streak` + дельты)
- [ ] `HistoryRow` (список завершённых сессий, `SessionRepository.history`)
- [ ] `SessionDetailView` + `SessionDetailViewModel` (read-only: упражнения, подходы `вес × повторы`, `totalTonnage`, длительность, PR)

**Критерий готовности:** график и метрики считаются по реальным данным с дельтами; открывается read-only Session Detail.

---

## Фаза 9 · Mascot Integration (2 дня)

Маскот — [AGENTS.md · Visual & Animation](../AGENTS.md). Пока **2 маскота**: `duck`, `baklazha` (ассеты — позже, набор расширяемый).

- [ ] Lottie SPM dependency
- [ ] JSON-анимации в `Resources/Lottie/`
- [ ] `MascotCanvas` с состояниями `idle / active / complete`
- [ ] Маппинг `Exercise.animationAssetName` → файл
- [ ] Выбор маскота через `UserProfile.selectedMascotId` (2 шт.)
- [ ] Плавное «схлопывание» при скролле (`matchedGeometryEffect`)

**Критерий готовности:** на Active Workout маскот зациклен и реагирует на состояние; в Exercise Detail показывает технику упражнения.

---

## Фаза 10 · Settings + Export (1–2 дня)

Экран — [userflow.md §9](userflow.md#9-таб-4--profile--settings); данные — `UserRepository`, `CSVExporter`.

- [ ] `SettingsViewModel` (`UserRepository.current` / `update`)
- [ ] `ProfileCard` + `MascotPreviewCard` → Mascot Picker (2 маскота)
- [ ] `SettingsGroup` + `SettingsRow` (с `KineticToggle`):
  - [ ] **TRAINING:** `defaultRestDuration`, единица веса `kg / lb` (`weightUnit`), `autoStartRestTimer`
  - [ ] **NOTIFICATIONS & FEEDBACK:** `restSoundEnabled`, `restHapticEnabled`
  - [ ] **DATA:** `Export to CSV`, `Clear workout history` (danger); Apple Health — позже
  - [ ] **ACCOUNT:** плейсхолдер (вход через Telegram OAuth — позже)
- [ ] `CSVExporter.exportHistory()` → `ShareLink(item: url)`
- [ ] `VersionFooter`

**Критерий готовности:** можно менять профиль/настройки/единицу веса, выбрать маскота, экспортировать историю в CSV.

---

## Фаза 11 · Polish & Performance (2–3 дня)

- [ ] Анимации SF Symbols 6 для таб-бара (`FloatingNavBar`)
- [ ] Haptic Feedback во всех нужных точках (`HapticsService`)
- [ ] Empty states для всех списков
- [ ] Локализация ru + en через xcstrings (каталог + UI) — см. memory `project_localization_strategy`
- [ ] Dynamic Type до AX1
- [ ] Accessibility labels для всех интерактивных элементов
- [ ] Snapshot-тесты ключевых экранов
- [ ] Профайлинг через Instruments (`RestTimerService`, графики)

**Критерий готовности:** все экраны полированы, snapshot-тесты зелёные, нет видимых рывков на 60fps.

---

## Сводная диаграмма зависимостей

```
Bootstrap ─► Data ─► Domain ─► Components ─► Onboarding + ProfileSetup ─┬─► Dashboard
                                                                         ├─► Library ──► Active Workout
                                                                         ├─► Builder
                                                                         ├─► Progress
                                                                         └─► Settings
                                                                             │
                                                                       Mascot Integration ─► Polish
```

Можно вести Library, Builder, Progress, Settings параллельно после Фазы 3.5.
Active Workout зависит от Library (нужен список упражнений для добавления сетов вне плана).

## Definition of Done для каждой фазы

- [ ] Код компилируется без warnings под Swift 6 Strict Concurrency
- [ ] SwiftLint проходит без ошибок
- [ ] Юнит-тесты добавлены/обновлены
- [ ] `#Preview` работает с in-memory контейнером
- [ ] Ручной smoke test на симуляторе iPhone 16 / iOS 18
- [ ] Документация в [docs/](.) обновлена при изменении контракта
