# FitnesApp

iOS приложение для тренировок с анимированным маскотом. Дизайн-система «Kinetic» — тёмная тема, неоново-лаймовые акценты, glassmorphism-навигация.

---

## Стек технологий

| Категория   | Технология                     |
| ----------- | ------------------------------ |
| Язык        | Swift 6.0 · Strict Concurrency |
| UI          | SwiftUI · iOS 18+              |
| Persistence | SwiftData                      |
| Charts      | Swift Charts                   |
| Анимации    | Lottie (JSON)                  |
| Уведомления | UserNotifications (локальные)  |
| Типографика | Space Grotesk · SF Pro         |
| Project Gen | XcodeGen                       |
| Lint        | SwiftLint                      |
| Тесты       | Swift Testing                  |

---

## Архитектура

MVVM + Services + Repositories поверх SwiftData. Зависимости направлены строго внутрь:

```
View → ViewModel → Service → Repository → SwiftData
```

Подробнее — в [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Быстрый старт

**Требования:** Xcode 16+, iOS 18 Simulator, Homebrew.

```bash
# Установить инструменты (если не установлены)
brew install xcodegen swiftlint

# Сгенерировать .xcodeproj
xcodegen generate

# Открыть проект
open FitnesApp.xcodeproj
```

---

## Структура проекта

```
FitnesApp/
├── App/              # Точка входа, роутер, DI
├── Core/             # Утилиты, логгер, ошибки
├── Data/             # SwiftData-модели, репозитории, сидинг
├── Domain/           # Сервисы, калькуляторы, бизнес-логика
├── Features/         # Экраны: Dashboard, Library, Workout, Progress, Settings
├── DesignSystem/     # Токены (цвета, типографика), компоненты UI
├── Resources/        # Шрифты, ассеты, Lottie-анимации
└── Tests/            # Юнит-тесты доменного и дата-слоя
```

---

## Документация

| Документ                                     | Содержание                     |
| -------------------------------------------- | ------------------------------ |
| [ARCHITECTURE.md](ARCHITECTURE.md)           | Чистая архитектура, ADR        |
| [design-system.md](design-system.md)         | Цвета, типографика, компоненты |
| [screens.md](screens.md)                     | UX-спецификация экранов        |
| [docs/roadmap.md](docs/roadmap.md)           | Поэтапный план разработки      |
| [docs/data-layer.md](docs/data-layer.md)     | SwiftData-модели и миграции    |
| [docs/domain-layer.md](docs/domain-layer.md) | Сервисы и репозитории          |
