# Role Definition & Agent Instructions (Project: Fitness Mascot App)

Манифест для AI-агентов и ведущих разработчиков проекта **KINETIC** — мобильного приложения на Swift 6.0 / SwiftUI.

Этот файл — **тонкий вход**: общие правила и карта документации. Детали каждого слоя живут в `docs/` (см. § Индекс документации) — это единственный источник правды, AGENTS.md их не дублирует.

---

## Общие параметры системы

- **ОС:** iOS 18.0+
- **Архитектура:** MVVM
- **Стек:** SwiftData, SwiftUI, SwiftUI.Charts, Lottie, UserNotifications, Swift 6 (Strict Concurrency), XcodeGen, SwiftLint, Swift-format (Built-in)
- **Дизайн:** Dark Mode Only, акцент lime `#d3f670`, Space Grotesk + системный SF, плавающий (floating pill) таб-бар. Токены — [docs/userflow.md](docs/userflow.md) § Design System.

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

## Роли агентов

Ниже — **цель** каждой роли. Конкретные зоны ответственности и реализация — в привязанных документах.

### 1. Архитектор системы (System Architect)
Масштабируемая структура приложения и схема данных: SwiftData-модели, репозитории, доменные сервисы, Strict Concurrency, конфигурация проекта (`project.yml`).
→ [docs/models.md](docs/models.md), [docs/data-layer.md](docs/data-layer.md), [docs/services-and-repository.md](docs/services-and-repository.md), [docs/concurrency.md](docs/concurrency.md)

### 2. UI/UX Инженер (SwiftUI Specialist)
Интерфейс по Apple HIG и финальному дизайну KINETIC: экраны, навигация, компоненты, таб-бар.
→ [docs/userflow.md](docs/userflow.md), [docs/feature-modules.md](docs/feature-modules.md), [docs/presentation-layer.md](docs/presentation-layer.md), [docs/ui-components.md](docs/ui-components.md)

### 3. Специалист по анимации и ассетам (Visual & Animation)
Анимированный маскот и медиа: Lottie/`.mov`, состояния `idle / active / complete`, выбор маскота. **Пока 2 маскота** — «утка» (`duck`) и «бакляха» (`baklazha`); ассеты будут позже, архитектуру выбора закладываем расширяемой.
→ [docs/maskot/](docs/maskot/), [docs/feature-modules.md](docs/feature-modules.md) (Active Workout, Exercise Detail)

### 4. Инженер по логике тренировок (Logic & Tracking)
Состояние тренировки, таймеры, прогрессия, восстановление сессии, локальные уведомления.
→ [docs/feature-modules.md](docs/feature-modules.md) § Active Workout, [docs/services-and-repository.md](docs/services-and-repository.md) (WorkoutService, ProgressionService, RestTimerService), [docs/concurrency.md](docs/concurrency.md)

---

## Индекс документации (`docs/`)

| Слой / тема              | Файл |
| ------------------------ | ---- |
| Модели данных (схема)    | [docs/models.md](docs/models.md) |
| Data Layer (контейнер, репозитории, сидинг, миграции) | [docs/data-layer.md](docs/data-layer.md) |
| Доменные сервисы и репозитории | [docs/services-and-repository.md](docs/services-and-repository.md) |
| Presentation (роутер, DI, ViewModels) | [docs/presentation-layer.md](docs/presentation-layer.md) |
| Фичи поэкранно           | [docs/feature-modules.md](docs/feature-modules.md) |
| UI-компоненты            | [docs/ui-components.md](docs/ui-components.md) |
| User Flow + Design System | [docs/userflow.md](docs/userflow.md) |
| Concurrency & Data Safety | [docs/concurrency.md](docs/concurrency.md) |
| Дорожная карта           | [docs/roadmap.md](docs/roadmap.md) |
| Макеты дизайна           | [docs/app-design/design-claude-code/](docs/app-design/design-claude-code/) |

> При расхождении AGENTS.md и `docs/` — **прав `docs/`**. Замеченное расхождение исправляем в этом манифесте, а не дублируем сюда деталь.

---

## Инструментарий и качество кода

- **XcodeGen:** репозиторий не содержит `.xcodeproj` (кроме временной отладки). Структура — в `project.yml`, генерация: `xcodegen generate`.
- **SwiftLint:** обязателен, конфиг `.swiftlint.yml`. Ошибки линтера исправляются немедленно.
- **Swift-format:** встроенный форматтер Xcode перед коммитом.
- **Strict Concurrency:** все модули компилируются без предупреждений Swift 6 Isolation.

---

## Протоколы взаимодействия

1. **Model-First:** любые изменения интерфейса начинаются с обновления модели SwiftData.
2. **Safety:** весь код проходит проверку компилятора Swift 6 на отсутствие data races.
3. **No Live Activities:** оперативная информация (таймеры) — внутри приложения или через локальные уведомления (`UserNotifications`).
4. **Tonnage First:** тоннаж (Weight × Reps) — главная метрика прогресса, денормализуется на всех уровнях модели.
