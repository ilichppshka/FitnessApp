# Concurrency & Data Safety

Правила Swift 6 Strict Concurrency для проекта.

## 1. Цель

Код компилируется без warnings под `SWIFT_STRICT_CONCURRENCY=complete`. Никаких `@unchecked Sendable`, никаких отключений изоляции в продакшен-коде.

## 2. Изоляция по слоям

| Слой | Изоляция | Обоснование |
| ---- | -------- | ----------- |
| `View` | implicit `@MainActor` (SwiftUI) | UI-обновления |
| `ViewModel` | `@MainActor` | UI-state, реакция на пользователя, таймеры |
| `Service` | `@MainActor` (по умолчанию) | Использует MainActor-репозитории |
| `Repository` (SwiftData) | `@MainActor` | `ModelContext` непригоден для пересечения акторов |
| `Repository` (background) | `actor` | Импорт/экспорт, тяжёлые операции |
| `CSVExporter` | `actor` | Файловый I/O |
| `TimerService` | `@MainActor` + `@Observable` | UI-биндинг |
| `NotificationService` | nonisolated (UNUserNotificationCenter сам управляет) | Системный API thread-safe |
| DTO | `Sendable struct` | Безопасный обмен между акторами |

## 3. ModelContext и SwiftData

**Правило:** `ModelContext` НЕ Sendable. Один контекст — один актор.

- **UI-контекст** живёт на `@MainActor` и принадлежит `ModelContainer.mainContext`.
- **Background-контекст** для импорта/экспорта создаётся внутри `actor` и не покидает его границ.
- Между акторами передаются ТОЛЬКО `Sendable`-DTO, никогда не `@Model`-объекты.

```swift
// ❌ Плохо
func sendToBackground(_ session: WorkoutSession) async {
    await BackgroundWorker.shared.process(session)   // session — не Sendable
}

// ✅ Хорошо
func sendToBackground(_ session: WorkoutSession) async {
    let dto = WorkoutSessionDTO(from: session)       // Sendable
    await BackgroundWorker.shared.process(dto)
}
```

## 4. Паттерны таймеров

### Таймер сессии

Время сессии — это `Date.now.timeIntervalSince(startedAt)`. **Не аккумулируем** счётчиком — рассчитываем при каждом тике. Это даёт корректность при уходе в фон.

```swift
@MainActor
@Observable
final class TimerService {
    private var task: Task<Void, Never>?

    func start(at startedAt: Date) {
        task?.cancel()
        task = Task { [weak self] in
            while !Task.isCancelled {
                self?.elapsed = Date.now.timeIntervalSince(startedAt)
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    deinit { task?.cancel() }
}
```

> `[weak self]` обязателен — Task держит сильную ссылку на захваченные значения.

### Таймер отдыха

Хранит `restEndsAt: Date`. По истечении — `restRemaining = 0`, `isRestRunning = false`. При фоне приложения система всё равно покажет уведомление через `UserNotifications`, поэтому корректность не теряется.

## 5. Async/await на границах

- **ViewModel** вызывает `await service.method()` из `@MainActor` контекста.
- **Service** вызывает `await repository.method()`, остаётся на MainActor.
- Когда нужна фоновая работа — явный `Task.detached` с `actor`-репозиторием.

```swift
@MainActor
func exportCSV() async throws -> URL {
    try await csvExporter.exportAll()   // csvExporter — actor, переключение происходит за нас
}
```

## 6. Sendable

Все DTO — `struct`, помеченные `Sendable`:

```swift
struct WorkoutSetDTO: Sendable, Identifiable, Hashable { ... }
```

Протоколы сервисов — `Sendable`:

```swift
protocol WorkoutServicing: Sendable { ... }
```

Это нужно, чтобы `DIContainer` (который `@Observable @MainActor`) мог безопасно держать ссылки на сервисы и передавать их в Task.

## 7. @Observable: подводные камни

- `@Observable` класс не обязан быть `@MainActor`, но если он содержит UI-state — должен быть. Иначе SwiftUI будет получать обновления с фонового потока → undefined behavior.
- Для observable, который читается из View, всегда `@MainActor`.

## 8. Запрещённые конструкции

| Конструкция | Замена |
| ----------- | ------ |
| `DispatchQueue.main.async` | `Task { @MainActor in ... }` или прямое нахождение на MainActor |
| `@unchecked Sendable` в продакшене | Корректное проектирование изоляции |
| Глобальные синглтоны без изоляции | `actor`-синглтон или `@MainActor`-синглтон |
| Передача `@Model` через async-границу | DTO |
| `Thread.sleep` | `try await Task.sleep(for:)` |
| `NotificationCenter.default.addObserver(...)` с захватом self | Использовать `for await` через `Notification.publisher` или явные таски |

## 9. Тестирование concurrency

- Юнит-тесты — `@Test func ...() async throws { ... }`.
- Каждый тест получает свежий MainActor-контекст SwiftData (in-memory).
- Race-conditions проверять через `TaskGroup`-сценарии: «10 параллельных logSet — все попадают в БД, totalTonnage корректный».

## 10. Чеклист на каждый PR

- [ ] Нет warnings `Sending '...' risks causing data races`.
- [ ] Нет `@unchecked Sendable`.
- [ ] DTO для всего, что пересекает акторы.
- [ ] ViewModel помечен `@MainActor`.
- [ ] Repository использует один и тот же `ModelContext` от создания до уничтожения.
- [ ] Tasks отменяются в `deinit`/при смене состояния.
