# Onboarding

Первое впечатление пользователя: 3 страницы, обучающие основной ценности приложения. Завершается переходом на [Profile Setup](profile-setup.md). Показывается только при первом запуске — флаг `onboardingCompleted` живёт в `UserDefaults` через `@AppStorage`.

## 1. Назначение

**Файлы:** `Features/Onboarding/`
**Цель:** Познакомить пользователя с тремя ключевыми возможностями (Log → Analyze → Train) перед тем, как просить создать профиль.

> Онбординг не сохраняет никаких данных в SwiftData. Единственное состояние — флаг `@AppStorage("onboardingCompleted")`, который выставляется в `true` уже после успешного сохранения `UserProfile` на экране [Profile Setup](profile-setup.md).

## 2. Состояние ViewModel

```swift
@MainActor @Observable
final class OnboardingFlowViewModel {
    enum Step: Int, CaseIterable, Hashable {
        case welcome, log, analyze
    }

    var currentStep: Step = .welcome
    var showsProfileSetup: Bool = false

    func next()              // welcome → log → analyze → showsProfileSetup = true
    func skip()              // любой шаг → showsProfileSetup = true
}
```

ViewModel не имеет зависимостей от репозиториев и сервисов — это чисто навигационное состояние. Создание `UserProfile` происходит уже внутри `ProfileSetupViewModel`.

## 3. Действия

| Действие | Метод |
| -------- | ----- |
| Тап CTA на Welcome | `next()` → `.log` |
| Тап CTA на Log | `next()` → `.analyze` |
| Тап CTA на Analyze | `next()` → `showsProfileSetup = true` |
| Свайп влево/вправо | биндинг к `currentStep` через `TabView(selection:)` |
| Тап `Skip` (top-right на любой странице) | `skip()` |

## 4. Жизненный цикл / Навигация

```
RootView (@AppStorage onboardingCompleted == false)
  └─ OnboardingFlowView
       ├─ TabView(.page) selection: currentStep
       │    ├─ OnboardingWelcomePage   (.welcome)
       │    ├─ OnboardingLogPage       (.log)
       │    └─ OnboardingAnalyzePage   (.analyze)
       └─ .fullScreenCover(isPresented: showsProfileSetup)
            └─ ProfileSetupView
                 └─ onComplete → @AppStorage onboardingCompleted = true
                              → RootView перерисовывается в TabView
```

Возврата назад из Profile Setup в онбординг нет — после `Skip` или прохождения трёх шагов пользователь обязан заполнить профиль. Закрытие через системный жест свайпа вниз отключено (`.interactiveDismissDisabled()`).

## 5. UI

Каждая страница использует общий контейнер `OnboardingPageScaffold`:

```
┌─────────────────────────────────┐
│ ProgressDots (3)         Skip → │   ← top bar
├─────────────────────────────────┤
│                                 │
│            HERO SLOT            │   ← уникально для каждой страницы
│                                 │
├─────────────────────────────────┤
│ eyebrow (SectionLabel)          │
│ title  (Font.App.headlineLg)    │
│ body   (Font.App.bodyMd)        │
├─────────────────────────────────┤
│       [ KineticButton CTA ]     │   ← bottom CTA
└─────────────────────────────────┘
```

### Welcome (OnB_01)

- Большой круг (≈ 180 pt) с иконкой молнии в центре.
- На старте — `Image(systemName: "bolt.fill")` как заглушка; бренд-SVG из `Resources/Assets.xcassets` подменяется в конце фазы.
- `NeonGlowModifier` на круге.
- Eyebrow `WELCOME TO KINETIC`, заголовок «Train like a laboratory.», CTA «Get Started».

### Log (OnB_02)

- `PerformanceCard` с демо: badge `SET 3 / 4`, два больших блока WEIGHT/REPS (статичные, не интерактивные), кнопка-плейсхолдер «✓ Complete Set».
- Eyebrow `01 · LOG`, заголовок «Every rep, captured.», CTA «Continue».

### Analyze (OnB_03)

- `PerformanceCard` со статистикой: бейдж `+6 NEW PRS`, число `72,840 kg`, mini-area-chart через Swift Charts (статичные демо-точки), три метрики `SESSIONS / STREAK / TIME` через `StatTriple`.
- Eyebrow `02 · ANALYZE`, заголовок «Watch yourself level up.», CTA «Start Training».

## 6. Используемые компоненты

| Компонент | Где |
| --------- | --- |
| `KineticButton` | bottom CTA на каждой странице |
| `ProgressDots` | индикатор 3 шагов в top bar |
| `PerformanceCard` | hero на Log и Analyze |
| `SectionLabel` | eyebrow-строки |
| `StatTriple` | метрики на Analyze |
| `NeonGlowModifier` | свечение круга на Welcome |
| `Color.App` / `Font.App` | токены везде |

Ничего нового в `DesignSystem` не добавляем.

## 7. Граничные случаи

- Пользователь нажал `Skip` на Welcome → сразу Profile Setup, без двух остальных страниц.
- Пользователь закрыл приложение посреди онбординга → при следующем запуске начинается заново с Welcome (флаг ещё `false`, состояние ViewModel не персистится).
- Пользователь сохранил профиль, потом удалил приложение → онбординг пройдёт повторно (UserDefaults очищается вместе с приложением).

## 8. Локализация

Ключи в `Localizable.xcstrings` (en + ru):

```
onboarding.skip
onboarding.welcome.eyebrow / title / body / cta
onboarding.log.eyebrow     / title / body / cta
onboarding.analyze.eyebrow / title / body / cta
onboarding.log.demo.set        // "SET 3 / 4"
onboarding.log.demo.weight     // "WEIGHT"
onboarding.log.demo.reps       // "REPS"
onboarding.log.demo.complete   // "Complete Set"
onboarding.analyze.demo.volumeLabel    // "TOTAL VOLUME"
onboarding.analyze.demo.prsBadge       // "+6 NEW PRS"
onboarding.analyze.demo.sessionsLabel  // "SESSIONS"
onboarding.analyze.demo.streakLabel    // "STREAK"
onboarding.analyze.demo.timeLabel      // "TIME"
```

## 9. Связанные документы

- [profile-setup.md](profile-setup.md) — что происходит после онбординга.
- [feature-modules.md](feature-modules.md) — общая декомпозиция фич-слоя.
- [presentation-layer.md](presentation-layer.md) — принципы View ↔ ViewModel.
- [ui-components.md](ui-components.md) — `KineticButton`, `PerformanceCard`, `ProgressDots`, `StatTriple`.
- Дизайн: [OnB_01_Welcome.png](app-design/screens/OnB_01_Welcome.png), [OnB_02_Log.png](app-design/screens/OnB_02_Log.png), [OnB_03_Analyze.png](app-design/screens/OnB_03_Analyze.png).
