# Profile Setup

Финальный шаг входа в приложение. После трёх страниц [онбординга](onboarding.md) пользователь заполняет минимальный профиль — имя, вес тела и маскота. Сохранение создаёт единственный `UserProfile` в SwiftData и переключает `@AppStorage("onboardingCompleted")` в `true`.

## 1. Назначение

**Файлы:** `Features/ProfileSetup/`
**Цель:** Собрать минимально необходимые данные пользователя, чтобы остальные фичи (Dashboard, Active Workout, Settings) могли опираться на `UserProfile`.

> При первом появлении экрана автоматически вызывается системный prompt `UNUserNotifications` (через `NotificationScheduling.requestAuthorizationIfNeeded()`). Что бы пользователь ни выбрал — он продолжает заполнять форму, отказ не блокирует флоу. Тогглы `restSoundEnabled` / `restHapticEnabled` в `UserProfile` создаются `true` независимо от ответа: они управляют поведением **внутри активной сессии** (звук/хаптика, когда приложение в foreground); системное разрешение нужно только для local notification в фоне.

## 2. Состояние ViewModel

```swift
@MainActor @Observable
final class ProfileSetupViewModel {
    var name: String = ""
    var bodyWeightKg: Double = 75            // дефолт для шкалы
    var selectedMascot: MascotOption = .athlete

    private(set) var isSaving: Bool = false
    private(set) var error: String?

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && bodyWeightKg > 0
    }

    init(users: any UserRepository,
         notifications: any NotificationScheduling,
         onComplete: @escaping @MainActor () -> Void)

    func requestNotificationPermissionIfNeeded() async    // .task у View
    func save() async                                     // создаёт/обновляет UserProfile → onComplete()
}
```

`MascotOption` — отдельный enum в `Components/MascotOption.swift`:

```swift
enum MascotOption: String, CaseIterable, Identifiable {
    case athlete, runner, yogi
    var id: String { rawValue }
    var systemImage: String { ... }   // SF Symbol заглушка до Фазы 9
    var titleKey: LocalizedStringKey { ... }
}
```

`rawValue` сохраняется в `UserProfile.selectedMascotId`. В Фазе 9 этот же `rawValue` будет ключом к Lottie-ассету.

## 3. Действия

| Действие | Метод |
| -------- | ----- |
| Ввод имени | биндинг `name` к `GhostInputField` |
| `+ / −` для веса | `bodyWeightKg += 0.5` / `-= 0.5` (clamp 30…200) |
| Тап карточки маскота | `selectedMascot = .runner` (single-select) |
| Тап CTA «Enter the Lab →» | `Task { await viewModel.save() }` |

Шаг ввода веса — `0.5 кг` (соответствует шагу штангового блина). Граничные значения: 30 кг — 200 кг.

## 4. Жизненный цикл

### appear (.task)

```
requestNotificationPermissionIfNeeded()
  ├─ guard !notificationPromptShown else { return }    // @AppStorage флаг
  ├─ try? await notifications.requestAuthorizationIfNeeded()
  │     // iOS показывает системный prompt; результат не блокирует форму
  └─ notificationPromptShown = true
```

Отказ или ошибка проглатываются — это пре-запрос, форма продолжает работать. Повторно iOS prompt не покажет (это политика системы), поэтому защищаемся `@AppStorage("notificationPromptShown")`, чтобы не дёргать центр зря.

### save

```
save()
  ├─ guard canSave else { return }
  ├─ isSaving = true
  ├─ try await users.upsert(
  │       name: name.trimmed,
  │       bodyWeight: bodyWeightKg,
  │       selectedMascotId: selectedMascot.rawValue,
  │       restSoundEnabled: true,
  │       restHapticEnabled: true)
  ├─ Haptic.success
  ├─ isSaving = false
  ├─ onComplete()                  // RootView переключает @AppStorage → TabView
  └─ catch: error = String(describing: ...); isSaving = false
```

`UserRepository.upsert` создаёт запись, если профиль ещё не существует (новая установка), иначе обновляет существующий — это покрывает кейс, когда пользователь удалил данные приложения, но `UserProfile` остался от предыдущей сборки.

## 5. UI

```
┌─────────────────────────────────────┐
│  FINAL STEP                         │   ← SectionLabel eyebrow
│  Set up your profile.               │   ← headline
│  one-line body                      │   ← supporting text
├─────────────────────────────────────┤
│        ⊙ AvatarCircle (initial)     │   ← превью аватара
├─────────────────────────────────────┤
│  YOUR NAME                          │
│  ┌───────────────────────────────┐  │
│  │ GhostInputField   "Alex"      │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  BODY WEIGHT                        │
│  ┌────┐   ┌─────────┐   ┌────┐      │
│  │ −  │   │  78 kg  │   │ +  │      │   ← IconChip × 2 + value
│  └────┘   └─────────┘   └────┘      │
├─────────────────────────────────────┤
│  PICK YOUR MASCOT                   │
│  ┌──────┐ ┌──────┐ ┌──────┐         │
│  │  ⚡  │ │  🏃  │ │  🧘  │         │   ← MascotPickerGrid (3 carts)
│  │Athl. │ │Runner│ │ Yogi │         │
│  └──────┘ └──────┘ └──────┘         │
├─────────────────────────────────────┤
│   [ Enter the Lab →   (primary) ]   │
└─────────────────────────────────────┘
```

- `AvatarCircle` берёт инициал из `name.first?.uppercased()` (или плейсхолдер при пустом имени).
- Выбранная карточка маскота получает `primary`-бордер и галочку (`IconChip` с `checkmark`).
- CTA дизейблится по `!viewModel.canSave` либо при `isSaving`.

## 6. Используемые компоненты

| Компонент | Где |
| --------- | --- |
| `KineticButton` | CTA «Enter the Lab →» |
| `GhostInputField` | поле «YOUR NAME» |
| `IconChip` | кнопки `+ / −` веса, чек-иконка в выбранной карточке маскота |
| `AvatarCircle` | превью аватара |
| `SectionLabel` | eyebrow + лейблы секций |
| `PerformanceCard` | обёртка для каждой группы поля |

## 7. Связь с моделью

`UserProfile` ([data-layer.md](data-layer.md)) хранится в единственном экземпляре. После `save()`:

| Поле | Источник |
| ---- | -------- |
| `id` | `UUID()` (новый) или существующий |
| `name` | `viewModel.name.trimmed` |
| `bodyWeight` | `viewModel.bodyWeightKg` |
| `selectedMascotId` | `selectedMascot.rawValue` |
| `restSoundEnabled` | `true` (дефолт) |
| `restHapticEnabled` | `true` (дефолт) |

## 8. Граничные случаи

- Пустое имя → CTA дизейблена.
- Вес 0 или > 200 → CTA дизейблена (защита на уровне `canSave`).
- Ошибка SwiftData при `upsert` → `error` отображается под CTA, `onboardingCompleted` не выставляется, пользователь остаётся на экране.
- Профиль уже существует (повторный заход не должен случиться при включённом `@AppStorage`, но защищаемся через `upsert`).

## 9. Локализация

```
profileSetup.eyebrow              // "FINAL STEP" / "ПОСЛЕДНИЙ ШАГ"
profileSetup.title                // "Set up your profile."
profileSetup.body                 // одна строка поддержки
profileSetup.name.label           // "YOUR NAME"
profileSetup.name.placeholder     // "Alex"
profileSetup.weight.label         // "BODY WEIGHT"
profileSetup.weight.unit          // "kg"
profileSetup.mascot.label         // "PICK YOUR MASCOT"
profileSetup.mascot.athlete       // "Athlete"
profileSetup.mascot.runner        // "Runner"
profileSetup.mascot.yogi          // "Yogi"
profileSetup.cta                  // "Enter the Lab"
profileSetup.error.generic        // "Couldn't save your profile. Try again."
```

## 10. Связанные документы

- [onboarding.md](onboarding.md) — что предшествует.
- [data-layer.md](data-layer.md) — модель `UserProfile` и `UserRepository`.
- [domain-layer.md](domain-layer.md) — `NotificationScheduling` и `NotificationService.requestAuthorizationIfNeeded()`.
- [feature-modules.md](feature-modules.md) — общая декомпозиция фич.
- [ui-components.md](ui-components.md) — `KineticButton`, `GhostInputField`, `AvatarCircle`, `IconChip`.
- Дизайн: [Profile Setup.png](app-design/screens/Profile%20Setup.png).
