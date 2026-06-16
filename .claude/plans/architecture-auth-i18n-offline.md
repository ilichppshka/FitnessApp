# Архитектура: i18n, offline-first и опциональная OAuth-авторизация (KINETIC)

## Context

Пользователь просил «продумать архитектуру» под стек из [AGENTS.md](AGENTS.md) с тремя требованиями: два языка (RU/EN), offline-first, и будущая авторизация через Yandex/Telegram OAuth2.

Исследование показало: проект **не greenfield**. Уже реализованы слои Data → Repository → Domain → Presentation (MVVM + DI), Design System (30+ компонентов), полная инфраструктура (XcodeGen, SwiftLint, Swift 6.2 strict concurrency, CI, тесты). **Offline-first и двуязычность архитектурно уже заложены.** Реально отсутствует только **слой авторизации** — он и есть основной предмет этого плана.

Решения пользователя (зафиксированы):
- **Auth опциональна, offline-first** — гейта на старте нет; вход подключается позже (онбординг «без аккаунта» / Настройки).
- **Бэкенд есть/будет** — проектируем под серверный обмен (секреты провайдеров живут на сервере, не в приложении).
- **Только идентичность** — вход даёт имя/аватар/provider-id; синхронизации данных нет, всё остаётся локально в SwiftData. `SyncService` не нужен.
- **Оба провайдера** (Telegram + Yandex) за провайдер-агностичной абстракцией.

Цель: спроектировать auth-слой, который встраивается в существующие слои без нарушения принципов (зависимости внутрь, `@MainActor`, Sendable-DTO между акторами, секреты только на бэкенде), и кратко зафиксировать, что offline-first/i18n уже на месте.

---

## Что УЖЕ на месте (подтверждение, не переделываем)

- **Offline-first** — `ModelContainer.makeProduction()` ([Data/ModelContainer+App.swift](FitnesApp/Data/ModelContainer+App.swift)) с `cloudKitDatabase: .none`; всё пишется локально, активная сессия восстанавливается по `finishedAt == nil`. Auth не должна это менять — приложение работает без входа.
- **Локализация RU/EN** — String Catalog'и `Localizable.xcstrings` (UI-хрома), `Exercises.xcstrings` (каталог через slug+перевод), `Onboarding.xcstrings`. Стратегия: slug/enum в БД, тексты в `.xcstrings`. Сейчас заполнен только RU, EN отложен (см. memory `Catalog data localization strategy`).
- **Малые пробелы (вне этого плана, отметить в roadmap):** EN-значения в каталогах не заполнены; полноценный Settings-экран — placeholder в [App/RootView.swift](FitnesApp/App/RootView.swift).

---

## Новый Auth-слой

Принцип: **бэкенд-опосредованный OAuth**. Приложение не хранит client-secret/bot-token и не парсит провайдер-специфичные ответы. Оно открывает `ASWebAuthenticationSession` на эндпоинт бэкенда `…/auth/{provider}/start`, бэкенд проводит OAuth-танец с провайдером, затем редиректит на кастомную схему `kinetic://auth/callback?token=…`. Это даёт единый провайдер-агностичный поток для Telegram и Yandex и держит все секреты на сервере.

### Зависимости
Только системные фреймворки — **никаких SPM-пакетов**: `AuthenticationServices` (`ASWebAuthenticationSession`), `Security` (Keychain), `URLSession`. Согласуется с текущим проектом без внешних зависимостей.

### 1. Data Layer

**Расширить [Data/Models/UserProfile.swift](FitnesApp/Data/Models/UserProfile.swift)** опциональными identity-полями (всё nullable — вход опционален). **Токены сюда НЕ кладём.**
```
var authProviderRaw: String?   // "telegram" | "yandex"
var providerUserId: String?
var email: String?
var displayName: String?       // имя из провайдера (отдельно от локального name)
var avatarURLString: String?
var linkedAt: Date?
```
- Новый enum `AuthProviderID: String, Codable, Sendable, CaseIterable { case telegram, yandex }` (в `Data/Models/` или `Domain/Auth/`).
- Обновить [Data/DTO/UserProfileDTO.swift](FitnesApp/Data/DTO/UserProfileDTO.swift) и [Data/DTO/Mappers.swift](FitnesApp/Data/DTO/Mappers.swift) теми же полями.
- Расширить `UserRepository` ([Data/Repositories/UserRepository.swift](FitnesApp/Data/Repositories/UserRepository.swift)): `func linkIdentity(_:) async throws` и `func clearIdentity() async throws` (либо переиспользовать `update`), сохраняя identity на singleton-профиль.

**Миграция:** добавить `SchemaV2` ([Data/Migrations/SchemaV1.swift](FitnesApp/Data/Migrations/SchemaV1.swift) рядом) с расширенным `UserProfile`, прописать lightweight-stage V1→V2 в [Data/Migrations/AppMigrationPlan.swift](FitnesApp/Data/Migrations/AppMigrationPlan.swift), обновить `appSchema`. Поля опциональные → миграция автоматическая. (Дев-фолбэк в `makeProduction` всё равно подстрахует стиранием стора, но правильный путь — SchemaV2.)

### 2. Безопасное хранилище токенов
- `Domain/Auth/TokenStore.swift` — протокол `TokenStore: Sendable` (`save/load/delete` по ключу).
- `KeychainTokenStore` поверх `Security` (kSecClassGenericPassword). Хранит **session-токен от бэкенда** (+ refresh, если есть). Никогда — в SwiftData.

### 3. Сетевой слой (тонкий)
- `Domain/Auth/AuthAPI.swift` — протокол `AuthAPI: Sendable`: `func session(forCallback url: URL) async throws -> AuthSession`, `func signOut(token:) async throws`.
- `URLSessionAuthAPI` — реализация на `URLSession`, base URL из конфига (см. §Config).
- Sendable-DTO: `AuthSession { token, refreshToken?, expiresAt?, identity }`, `AuthIdentity { providerID, providerUserId, displayName, email?, avatarURL? }`.

### 4. OAuth-поток (провайдер-агностичный, мокаемый seam)
- `Domain/Auth/OAuthFlow.swift` — протокол `OAuthFlow: Sendable`: `@MainActor func start(provider: AuthProviderID) async throws -> URL` (возвращает callback-URL с токеном).
- `WebAuthenticationFlow` — реализация на `ASWebAuthenticationSession`: открывает `{AUTH_BASE_URL}/auth/{provider}/start?redirect=kinetic://auth/callback`, ждёт callback по схеме `kinetic`. Включает `ASWebAuthenticationPresentationContextProviding` (anchor на `@MainActor`). Провайдер — лишь параметр пути, поэтому поток един для обоих.

### 5. Domain: AuthService (оркестратор)
- `Domain/Protocols/AuthServicing.swift` — протокол (по образцу `WorkoutServicing`/`AnalyticsServicing` в [Domain/Protocols/](FitnesApp/Domain/Protocols/)):
  - `var state: AuthState` (`.anonymous | .authenticating | .authenticated(AuthIdentity) | .failed(String)`)
  - `func signIn(with: AuthProviderID) async throws`
  - `func signOut() async throws`
  - `func restore() async`
- `Domain/Auth/AuthService.swift` — `@Observable @MainActor`, зависит от `OAuthFlow`, `AuthAPI`, `TokenStore`, `UserRepository`.
  - **signIn:** `OAuthFlow.start` → `AuthAPI.session(forCallback:)` → токен в Keychain → identity в `UserProfile` через репозиторий → `state = .authenticated`.
  - **signOut:** удалить токен из Keychain, очистить identity-поля профиля (локальные тренировки сохраняются — identity-only), `state = .anonymous`.
  - **restore:** на старте загрузить токен из Keychain, выставить state (без сетевого вызова, если токен валиден; опц. `me`-проверка позже).
- Расширить [Domain/AppError.swift](FitnesApp/Domain/AppError.swift): `case authCancelled`, `case authFailed(String)`, `case authNetwork(String)`.

### 6. DI
- В [App/DIContainer.swift](FitnesApp/App/DIContainer.swift) добавить `let authService: any AuthServicing`, собрать из `KeychainTokenStore`, `URLSessionAuthAPI(baseURL:)`, `WebAuthenticationFlow`, `userRepository`.

### 7. Presentation
- Новый модуль `Features/Auth/`: `AccountConnectView` (две кнопки — Telegram, Yandex — на дизайн-токенах KINETIC) + `AccountConnectViewModel` (зависит от `AuthServicing`, отражает `state`/ошибки/спиннер).
- **Точка входа 1 — онбординг:** опциональный, **пропускаемый** шаг с `AccountConnectView` + «Продолжить без аккаунта» в [Features/Onboarding/](FitnesApp/Features/Onboarding/) / рядом с [Features/ProfileSetup/ProfileSetupView.swift](FitnesApp/Features/ProfileSetup/ProfileSetupView.swift). Skip не блокирует завершение онбординга.
- **Точка входа 2 — Settings:** заменить placeholder-таб в [App/RootView.swift](FitnesApp/App/RootView.swift) на минимальный `Features/Settings/SettingsView` с секцией **Account**: если `.anonymous` — `AccountConnectView`; если `.authenticated` — имя/аватар провайдера + «Выйти». (Полный Settings — отдельный пункт roadmap.)
- **Старт приложения:** в [App/FitnesAppApp.swift](FitnesApp/App/FitnesAppApp.swift) / RootView добавить `.task { await container.authService.restore() }`. **Гейта нет** — UI рендерится независимо от состояния auth.
- Аватар/имя в Dashboard и Settings: при `.authenticated` предпочитать `displayName`/`avatarURL`, иначе локальный `UserProfile.name`.

### 8. Config / Info.plist (через [project.yml](project.yml))
- Зарегистрировать кастомную схему в `targets.FitnesApp.info.properties`:
  - `CFBundleURLTypes` со схемой `kinetic` (callback `kinetic://auth/callback`).
- `AUTH_BASE_URL` — ключ в Info.plist (или xcconfig), читается `AppConfig`-обёрткой; разные значения для dev/prod. Никаких секретов в бандле.
- После правок `project.yml` — `xcodegen generate` (хук уже настроен).

### 9. Concurrency (Swift 6.2 strict)
- `AuthService`, `WebAuthenticationFlow`, ViewModels — `@MainActor` (совпадает с `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor`).
- Все DTO (`AuthSession`, `AuthIdentity`) — `Sendable struct`. Между акторами — только DTO, не `@Model`.
- `TokenStore`/`AuthAPI` — `Sendable`; Keychain-вызовы синхронны и потокобезопасны.
- Сборка без warnings strict concurrency.

### 10. Локализация auth
- UI-строки auth → `Localizable.xcstrings`, онбординг-шаг → `Onboarding.xcstrings`. **RU-first** по текущей стратегии (EN — в фазе локализации). Ошибки auth — локализуемые ключи.

---

## Критичные файлы

**Новые:** `Domain/Auth/{AuthProviderID, OAuthFlow, WebAuthenticationFlow, AuthAPI, URLSessionAuthAPI, TokenStore, KeychainTokenStore, AuthService, AuthSession+DTO}.swift`, `Domain/Protocols/AuthServicing.swift`, `Features/Auth/{AccountConnectView, AccountConnectViewModel}.swift`, `Features/Settings/SettingsView.swift`, `Data/Migrations/SchemaV2.swift`.

**Изменяемые:** [UserProfile.swift](FitnesApp/Data/Models/UserProfile.swift), [UserProfileDTO.swift](FitnesApp/Data/DTO/UserProfileDTO.swift), [Mappers.swift](FitnesApp/Data/DTO/Mappers.swift), [UserRepository.swift](FitnesApp/Data/Repositories/UserRepository.swift), [ModelContainer+App.swift](FitnesApp/Data/ModelContainer+App.swift), [AppMigrationPlan.swift](FitnesApp/Data/Migrations/AppMigrationPlan.swift), [AppError.swift](FitnesApp/Domain/AppError.swift), [DIContainer.swift](FitnesApp/App/DIContainer.swift), [RootView.swift](FitnesApp/App/RootView.swift), [FitnesAppApp.swift](FitnesApp/App/FitnesAppApp.swift), [project.yml](project.yml), `Resources/Localizable.xcstrings`, `Resources/Onboarding.xcstrings`.

---

## Тесты (Swift Testing, по образцу [Tests/DomainTests/](FitnesApp/Tests/DomainTests/))
- `AuthServiceTests`: моки `OAuthFlow`/`AuthAPI`, in-memory `TokenStore`, in-memory `UserRepository`. Проверить: signIn сохраняет токен+identity и `state=.authenticated`; signOut чистит токен+identity, тренировки целы; restore поднимает state из Keychain; отмена web-сессии → `authCancelled`.
- `AccountConnectViewModelTests`: переходы состояний/ошибки.
- Моки — в `Tests/DomainTests/Mocks/`.

---

## План по фазам
1. **Data:** identity-поля в `UserProfile` + DTO/Mappers + `AuthProviderID` + `SchemaV2`/миграция + методы репозитория. Тесты репозитория зелёные.
2. **Domain core:** `TokenStore`/Keychain, `AuthAPI`/`URLSession`, `OAuthFlow`/`ASWebAuthenticationSession`, `AuthService`, `AppError`-кейсы. `AuthServiceTests`.
3. **DI + Config:** `DIContainer`, `project.yml` (URL-схема + `AUTH_BASE_URL`), `restore()` на старте (без гейта).
4. **UI:** `Features/Auth` (AccountConnect), опциональный шаг онбординга со skip, минимальный `Settings → Account`. ViewModel-тесты, `#Preview`.

---

## Verification
- `xcodegen generate`, затем сборка под iOS-симулятор через **XcodeBuildMCP** (`session_show_defaults` → `build_sim`/`build_run_sim`) — без warnings Swift 6 strict concurrency.
- `swiftlint --strict` — чисто (хуки уже настроены).
- Прогон `FitnesAppTests` (XcodeBuildMCP `test_sim`) — auth-тесты зелёные.
- Ручной smoke на симуляторе:
  1. Первый запуск без входа → онбординг **пропускается** без аккаунта → Dashboard работает полностью (offline-first сохранён).
  2. Settings → Account → кнопка провайдера открывает `ASWebAuthenticationSession`; после callback `kinetic://auth/callback?token=…` → state `.authenticated`, отображаются имя/аватар.
  3. «Выйти» → identity очищается, локальные тренировки на месте.
  4. (Бэкенд может быть замокан стаб-эндпоинтом, пока сервер не готов — слой к нему уже готов.)
