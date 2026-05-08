# Архитектура Fitness Mascot App

> Главный архитектурный документ. Здесь высокоуровневое описание; детали — в файлах [docs/](docs/).

## TL;DR

- **Платформа:** iOS 18.0+, Swift 6.0 (Strict Concurrency), SwiftUI, SwiftData.
- **Архитектура:** MVVM + слой сервисов + репозитории. Чистое разделение `View ↔ ViewModel ↔ Service ↔ Repository ↔ SwiftData`.
- **Принципы:** Model-First, Tonnage-First, Single ModelContext per Actor, Dark Mode Only, отсутствие Live Activities.
- **Дизайн-система:** «Kinetic Laboratory» — см. [design-system.md](design-system.md).

---

## 1. Карта документации

| Документ                                                 | Назначение                                     |
| -------------------------------------------------------- | ---------------------------------------------- |
| [ARCHITECTURE.md](ARCHITECTURE.md)                       | Общая картина (вы здесь)                       |
| [docs/project-structure.md](docs/project-structure.md)   | Файловая структура, модули, XcodeGen           |
| [docs/data-layer.md](docs/data-layer.md)                 | SwiftData-модели, связи, миграции              |
| [docs/domain-layer.md](docs/domain-layer.md)             | Services, Repositories, бизнес-логика          |
| [docs/presentation-layer.md](docs/presentation-layer.md) | Views, ViewModels, навигация, состояние        |
| [docs/concurrency.md](docs/concurrency.md)               | Правила Swift 6 Concurrency, акторы, контексты |
| [docs/feature-modules.md](docs/feature-modules.md)       | Каждый экран → ViewModel → зависимости         |
| [docs/roadmap.md](docs/roadmap.md)                       | Поэтапный план разработки                      |
| [AGENTS.md](AGENTS.md)                                   | Роли AI-агентов и их зоны ответственности      |
| [screens.md](screens.md)                                 | UX-спецификация экранов                        |
| [design-system.md](design-system.md)                     | Цвета, типографика, компоненты                 |

---

## 2. Чистая архитектура

```
┌──────────────────────────────────────────────────────────────────┐
│                           App Layer                              │
│   FitnesAppApp.swift · AppRouter · DI Container · ModelContainer │
└───────────────────────────────┬──────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────┐
│                       Presentation Layer                          │
│   SwiftUI Views ── @Observable ViewModels ── Navigation State    │
│   Dashboard · ExerciseLibrary · WorkoutBuilder ·                 │
│   ActiveWorkout · Progress · Settings                            │
└───────────────────────────────┬──────────────────────────────────┘
                                │  protocols
┌───────────────────────────────▼──────────────────────────────────┐
│                          Domain Layer                             │
│   WorkoutService · AnalyticsService · TimerService ·             │
│   NotificationService · CSVExporter                              │
└───────────────────────────────┬──────────────────────────────────┘
                                │  protocols
┌───────────────────────────────▼──────────────────────────────────┐
│                       Repository Layer                            │
│   ExerciseRepository · WorkoutRepository ·                       │
│   SessionRepository · UserRepository                             │
└───────────────────────────────┬──────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────┐
│                          Data Layer                               │
│   SwiftData @Model + ModelContainer + ModelContext               │
│   (MainActor context for UI, background context for I/O)         │
└──────────────────────────────────────────────────────────────────┘

  ┌─────────────────────┐  ┌─────────────────────┐  ┌──────────────┐
  │  UserNotifications  │  │   Lottie / .mov     │  │  SwiftCharts │
  └─────────────────────┘  └─────────────────────┘  └──────────────┘
```

### Правила слоёв

1. **View** не имеет доступа к `ModelContext` напрямую — только через ViewModel.
2. **ViewModel** не импортирует `SwiftData` — общается только через протоколы сервисов/репозиториев.
3. **Service** оркестрирует несколько репозиториев и инкапсулирует бизнес-логику (расчёт тоннажа, валидация сета, агрегация).
4. **Repository** — единственный, кто работает с `ModelContext`. Скрывает SwiftData за чистыми Swift-типами или DTO.
5. **Зависимости направлены внутрь:** Presentation → Domain → Data. Обратные зависимости запрещены.

---

## 3. Ключевые архитектурные решения (ADR-кратко)

| #   | Решение                                                       | Обоснование                                                                                   |
| --- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| 1   | MVVM, без Coordinator                                         | iOS 18 `NavigationStack` + `@Observable` достаточен; Coordinator избыточен для 6 экранов      |
| 2   | Repository поверх SwiftData                                   | Изоляция от SwiftData API, тестируемость через моки протоколов                                |
| 3   | Денормализованный `tonnage` в `WorkoutSet` и `WorkoutSession` | Графики тоннажа за период не должны триггерить агрегацию по тысячам сетов                     |
| 4   | `@MainActor` ViewModels                                       | Все обновления UI и таймеры — на главном акторе; фоновый контекст только для импорта/экспорта |
| 5   | Sendable-DTO между слоями                                     | Передача между акторами без data races                                                        |
| 6   | XcodeGen, без `.xcodeproj` в репо                             | Чистый diff, отсутствие конфликтов в pbxproj                                                  |
| 7   | Локальные уведомления вместо Live Activities                  | По требованию: вся индикация — внутри приложения или через `UserNotifications`                |
| 8   | Dark Mode Only                                                | UX в зале + дизайн-система Kinetic Laboratory                                                 |

---

## 4. Принципы (для каждого PR)

- **Model-First.** Любая фича начинается с модели/миграции, потом сервис, потом UI.
- **Tonnage First.** Тоннаж — главная метрика. Денормализуется и считается в `WorkoutService`, не в UI.
- **No Data Races.** Код компилируется без warnings под Swift 6 Strict Concurrency.
- **Pure ViewModels.** ViewModel не знает про SwiftUI (ни `View`, ни `EnvironmentObject`).
- **Restoration by Default.** Активная сессия (`finishedAt == nil`) восстанавливается при старте приложения.
- **Test the Domain.** Юнит-тесты обязательны для `WorkoutService` и `AnalyticsService`. UI-тесты — по необходимости.

---

## 5. Технологический стек

| Категория   | Технология                                  |
| ----------- | ------------------------------------------- |
| Язык        | Swift 6.0 (Strict Concurrency)              |
| UI          | SwiftUI (iOS 18)                            |
| Persistence | SwiftData                                   |
| Charts      | Swift Charts                                |
| Анимации    | Lottie (`.json`) или `.mov` с альфа-каналом |
| Уведомления | UserNotifications (локальные)               |
| Project Gen | XcodeGen (`project.yml`)                    |
| Lint/Format | SwiftLint + Swift-format (встроенный)       |
| Тесты       | Swift Testing (`@Test`, `#expect`)          |
| DI          | Конструкторная инъекция через протоколы     |

---

## 6. Что дальше

1. Прочитать [docs/project-structure.md](docs/project-structure.md) и сгенерировать скелет.
2. Реализовать Data Layer по [docs/data-layer.md](docs/data-layer.md).
3. Реализовать Domain Layer по [docs/domain-layer.md](docs/domain-layer.md).
4. Поднять первый экран (Dashboard) по [docs/presentation-layer.md](docs/presentation-layer.md).
5. Следовать поэтапному плану в [docs/roadmap.md](docs/roadmap.md).
