# Project Structure

Описание файловой структуры, модулей и сборки.

## 1. Корень репозитория

```
FitnesApp/
├── ARCHITECTURE.md              # Корневой архитектурный документ
├── AGENTS.md                    # Роли AI-агентов
├── screens.md                   # UX-спецификация
├── design-system.md             # Дизайн-система
├── project.yml                  # XcodeGen конфигурация
├── .swiftlint.yml               # Конфигурация линтера
├── .swift-format                # Конфигурация форматтера
├── Maskot/                      # Исходники маскота (PNG, MP4)
├── docs/                        # Архитектурные документы
└── FitnesApp/                   # Исходный код приложения
    ├── App/
    ├── Core/
    ├── Data/
    ├── Domain/
    ├── Features/
    ├── DesignSystem/
    ├── Resources/
    └── Tests/
```

## 2. Структура `FitnesApp/`

```
FitnesApp/
├── App/
│   ├── FitnesAppApp.swift           # @main, ModelContainer, root view
│   ├── AppRouter.swift              # NavigationStack root state
│   ├── DIContainer.swift            # Конструкторная инъекция сервисов
│   └── ModelContainer+Setup.swift   # SwiftData schema, migration plan
│
├── Core/
│   ├── Concurrency/
│   │   ├── MainActor+Helpers.swift
│   │   └── BackgroundContext.swift  # Изолированный actor для I/O
│   ├── Persistence/
│   │   ├── ModelContextProvider.swift
│   │   └── PreviewContainer.swift   # In-memory ModelContainer для превью/тестов
│   ├── Utilities/
│   │   ├── Date+Week.swift
│   │   ├── Double+Formatting.swift
│   │   └── Logger+Extensions.swift  # OSLog обёртки по доменам
│   └── Errors/
│       └── AppError.swift           # Унифицированная ошибка на границах слоёв
│
├── Data/
│   ├── Models/                       # @Model SwiftData
│   │   ├── MuscleGroup.swift
│   │   ├── Exercise.swift
│   │   ├── PersonalRecord.swift
│   │   ├── WorkoutPlan.swift
│   │   ├── PlanExercise.swift
│   │   ├── WorkoutSession.swift
│   │   ├── WorkoutSet.swift
│   │   └── UserProfile.swift
│   ├── DTO/                          # Sendable-снимки для пересечения акторов
│   │   ├── ExerciseDTO.swift
│   │   ├── WorkoutSessionDTO.swift
│   │   └── WorkoutSetDTO.swift
│   ├── Repositories/
│   │   ├── ExerciseRepository.swift
│   │   ├── WorkoutRepository.swift
│   │   ├── SessionRepository.swift
│   │   └── UserRepository.swift
│   ├── Seed/
│   │   ├── ExerciseSeed.swift        # Базовый каталог упражнений
│   │   └── MuscleGroupSeed.swift
│   └── Migrations/
│       └── SchemaV1.swift
│
├── Domain/
│   ├── Services/
│   │   ├── WorkoutService.swift
│   │   ├── AnalyticsService.swift
│   │   ├── TimerService.swift
│   │   ├── NotificationService.swift
│   │   └── CSVExporter.swift
│   ├── Protocols/                    # Контракты для DI и тестов
│   │   ├── WorkoutServicing.swift
│   │   ├── AnalyticsServicing.swift
│   │   └── NotificationScheduling.swift
│   └── Calculators/
│       ├── TonnageCalculator.swift
│       └── PersonalRecordCalculator.swift
│
├── Features/                         # По одному модулю на экран
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── DashboardViewModel.swift
│   │   └── Components/
│   │       ├── WeekCalendarStrip.swift
│   │       ├── NextWorkoutCard.swift
│   │       └── WeeklyStatsRing.swift
│   ├── ExerciseLibrary/
│   │   ├── ExerciseLibraryView.swift
│   │   ├── ExerciseLibraryViewModel.swift
│   │   ├── ExerciseDetailSheet.swift
│   │   └── Components/
│   │       └── MuscleGroupChip.swift
│   ├── WorkoutBuilder/
│   │   ├── WorkoutBuilderView.swift
│   │   ├── WorkoutBuilderViewModel.swift
│   │   └── Components/
│   │       └── PlanExerciseRow.swift
│   ├── ActiveWorkout/
│   │   ├── ActiveWorkoutView.swift
│   │   ├── ActiveWorkoutViewModel.swift
│   │   └── Components/
│   │       ├── MascotStage.swift
│   │       ├── SetInputPanel.swift
│   │       └── RestTimerBar.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   ├── ProgressViewModel.swift
│   │   └── Components/
│   │       ├── TonnageChart.swift
│   │       └── SessionHistoryRow.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── SettingsViewModel.swift
│       └── Components/
│           └── MascotPicker.swift
│
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift              # Палитра Kinetic Laboratory
│   │   ├── Typography.swift          # Space Grotesk + SF Pro
│   │   ├── Spacing.swift
│   │   └── Radii.swift
│   ├── Components/
│   │   ├── KineticButton.swift
│   │   ├── PerformanceCard.swift
│   │   ├── FloatingNavPill.swift
│   │   ├── GhostInputField.swift
│   │   └── NeonGlowModifier.swift
│   └── Theme.swift                   # Корневой ViewModifier с Dark-only темой
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Lottie/
│   │   └── *.json
│   ├── Mascot/                       # Финальные оптимизированные ассеты
│   ├── Fonts/
│   │   ├── SpaceGrotesk-*.otf
│   │   └── ...
│   └── Localizable.xcstrings
│
└── Tests/
    ├── DomainTests/
    │   ├── WorkoutServiceTests.swift
    │   ├── AnalyticsServiceTests.swift
    │   └── TonnageCalculatorTests.swift
    ├── DataTests/
    │   ├── ExerciseRepositoryTests.swift
    │   └── SessionRepositoryTests.swift
    └── Mocks/
        ├── MockWorkoutRepository.swift
        ├── MockSessionRepository.swift
        └── PreviewModelContainer.swift
```

## 3. Модульные границы

Каждый каталог — логический модуль. Допустимые направления импорта:

```
Features  →  Domain        ✅
Features  →  DesignSystem  ✅
Features  →  Data          ❌ (только через Domain)
Domain    →  Data          ✅
Domain    →  Features      ❌
Data      →  Domain        ❌
Data      →  Features      ❌
DesignSystem → *           ❌ (полностью изолирован)
```

Правило: если возникает желание импортировать «вверх» — нужен новый протокол в нижнем слое.

## 4. XcodeGen (`project.yml`)

```yaml
name: FitnesApp
options:
  bundleIdPrefix: com.kinetic
  deploymentTarget:
    iOS: "18.0"
  createIntermediateGroups: true

settings:
  base:
    SWIFT_VERSION: "6.0"
    SWIFT_STRICT_CONCURRENCY: complete
    SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES: YES
    DEVELOPMENT_TEAM: "<TEAM_ID>"
    ENABLE_USER_SCRIPT_SANDBOXING: YES

packages:
  Lottie:
    url: https://github.com/airbnb/lottie-spm
    from: "4.5.0"

targets:
  FitnesApp:
    type: application
    platform: iOS
    sources:
      - path: FitnesApp
        excludes:
          - "Tests/**"
    resources:
      - FitnesApp/Resources
    dependencies:
      - package: Lottie
    info:
      path: FitnesApp/Resources/Info.plist
      properties:
        UIUserInterfaceStyle: Dark
        UILaunchScreen: {}
        NSUserNotificationsUsageDescription: "Уведомление об окончании таймера отдыха"

  FitnesAppTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - FitnesApp/Tests
    dependencies:
      - target: FitnesApp
```

Команда генерации: `xcodegen generate`.

`.xcodeproj` добавляется в `.gitignore`.

## 5. Линт и форматирование

**`.swiftlint.yml`** — базово:
```yaml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - explicit_init
  - sorted_imports
  - first_where
  - redundant_nil_coalescing
line_length: 140
file_length:
  warning: 500
  error: 800
identifier_name:
  excluded: [id, x, y, dx, dy]
included:
  - FitnesApp
excluded:
  - FitnesApp/Resources
```

**Swift-format** — встроенный в Xcode 16. Запуск перед коммитом через pre-commit hook (опционально).

## 6. Bootstrap-чеклист

- [ ] Установить XcodeGen: `brew install xcodegen`
- [ ] Установить SwiftLint: `brew install swiftlint`
- [ ] Создать `project.yml` (см. выше)
- [ ] Создать каталог `FitnesApp/` со скелетом из раздела 2
- [ ] Запустить `xcodegen generate`
- [ ] Открыть `FitnesApp.xcodeproj`, убедиться, что компилируется
- [ ] Подключить шрифты Space Grotesk через `UIAppFonts`
