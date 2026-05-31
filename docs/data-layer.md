# Data Layer

SwiftData-модели, репозитории, миграции, сидинг.

> **Канонический справочник по схеме — [models.md](models.md)** (полный список полей + UML-диаграмма). Этот документ повторяет модели и описывает реализацию слоя данных: `ModelContainer`, репозитории, DTO, сидинг, миграции.

## 1. Схема данных

10 `@Model`-сущностей + 4 enum. Владение (`.cascade`) показано стрелкой `═►`, ссылки (`.nullify`) — `──►`.

```
UserProfile (singleton)

MuscleGroup ◄── ExerciseMuscle ──► Exercise ═► PersonalRecord
                 (role: primary/secondary)        ▲     ▲
                                                   │     │
WorkoutPlan ═► PlanExercise ═► PlanSet             │     │
     ▲              └──────────────────────────────┘     │
     │ (nullify)                                          │
WorkoutSession ═► WorkoutSet ────────────────────────────┘
```

Визуальная UML-диаграмма связей — в [models.md · §7](models.md#7-uml-диаграмма-mermaid).

### Принципы моделирования

- **UUID-идентификаторы.** У каждой сущности `var id: UUID`; у корневых/справочных — `@Attribute(.unique)`.
- **Cascade delete.** План → `PlanExercise` → `PlanSet`; сессия → `WorkoutSet`; упражнение → `PersonalRecord` и `ExerciseMuscle`; группа мышц → `ExerciseMuscle`.
- **Nullify-ссылки.** Удаление справочного `Exercise`/`WorkoutPlan` не рушит историю: ссылки обнуляются (`PlanExercise.exercise`, `WorkoutSet.exercise`, `WorkoutSession.plan`).
- **Join для роли мышцы.** `ExerciseMuscle` хранит `role` (primary/secondary), т.к. в SwiftData нельзя положить атрибут на саму many-to-many связь.
- **Денормализация tonnage.** `WorkoutSet.tonnage = weight * reps`; `WorkoutSession.totalTonnage = Σ sets.tonnage`. Считается в `WorkoutService` при логировании сета и финализации.
- **Derived-свойства** (не хранятся): `Exercise.primary/secondaryMuscles`, `WorkoutPlan.totalSets/targetMuscleGroups`, `PlanExercise.targetSets`, `WorkoutSession.isActive/duration/containsPR`.
- **Inverse relationships** объявляются явно через `@Relationship(inverse:)`.

## 2. Модели

### Перечисления

```swift
import Foundation
import SwiftData

enum WeightUnit: String, Codable, CaseIterable { case kg, lb }

enum Difficulty: String, Codable, CaseIterable { case beginner, intermediate, advanced }

/// Тег оборудования (Barbell / Cable / … в Library и Exercise Detail).
enum Equipment: String, Codable, CaseIterable {
    case barbell, dumbbell, cable, machine, bodyweight, kettlebell, band, other
}

/// Роль мышцы в упражнении.
enum MuscleRole: String, Codable { case primary, secondary }
```

### `UserProfile` — профиль + настройки (singleton)

```swift
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var bodyWeight: Double                  // в единицах weightUnit
    var heightCm: Double?
    var weightUnit: WeightUnit              // kg / lb (Settings)
    var selectedMascotId: String            // "duck" | "baklazha"; расширяемо

    var defaultRestDuration: TimeInterval   // дефолт для новых PlanExercise
    var autoStartRestTimer: Bool            // авто-старт отдыха после Complete Set
    var restSoundEnabled: Bool              // Rest timer alerts
    var restHapticEnabled: Bool             // Haptic feedback

    var createdAt: Date

    init(...) { ... }
}
```

> Хранится в единственном экземпляре. Доступ — `UserRepository.current()`; при отсутствии создаётся дефолтный (`weightUnit = .kg`, маскот `"duck"`). Флаг «онбординг пройден» — `@AppStorage("onboardingCompleted")`, не в модели.

### `MuscleGroup`

```swift
@Model
final class MuscleGroup {
    @Attribute(.unique) var id: UUID
    var name: String                        // "Chest", "Back", …
    var displayOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.muscleGroup)
    var exerciseLinks: [ExerciseMuscle] = []

    init(...) { ... }
}
```

### `ExerciseMuscle` — join «упражнение ↔ мышца»

```swift
@Model
final class ExerciseMuscle {
    @Attribute(.unique) var id: UUID
    var role: MuscleRole                    // primary / secondary
    var exercise: Exercise?
    var muscleGroup: MuscleGroup?

    init(...) { ... }
}
```

### `Exercise`

```swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionStart: String            // SETUP
    var descriptionExecution: String        // EXECUTION
    var descriptionErrors: String           // COMMON MISTAKES
    var difficulty: Difficulty
    var equipment: Equipment
    var animationAssetName: String?         // Lottie/.mov демо
    var isFavorite: Bool                    // ⭐

    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.exercise)
    var muscleLinks: [ExerciseMuscle] = []

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord] = []

    var primaryMuscles: [MuscleGroup] {
        muscleLinks.filter { $0.role == .primary }.compactMap(\.muscleGroup)
    }
    var secondaryMuscles: [MuscleGroup] {
        muscleLinks.filter { $0.role == .secondary }.compactMap(\.muscleGroup)
    }

    init(...) { ... }
}
```

> `Est. 1RM` и `Attempts` (Exercise Detail) — **не хранятся**, считаются в `AnalyticsService`.

### `PersonalRecord`

```swift
@Model
final class PersonalRecord {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise?
    var date: Date
    var weight: Double
    var reps: Int
    var tonnage: Double                     // weight * reps, денормализовано

    init(...) { ... }
}
```

### `WorkoutPlan`

```swift
@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var name: String                        // "Push Day"
    var category: String?                   // "UPPER / PULL"
    var coverImageName: String?
    var accentColorHex: String?
    var scheduledWeekdays: [Int]            // 1...7 (Calendar.weekday) — week strip
    var isDraft: Bool                       // Save Draft vs Save Plan
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PlanExercise.plan)
    var planExercises: [PlanExercise] = []  // сортировка по .order

    var totalSets: Int { planExercises.reduce(0) { $0 + $1.targetSets } }
    var targetMuscleGroups: [MuscleGroup] {
        Array(Set(planExercises.compactMap(\.exercise).flatMap(\.primaryMuscles)))
    }

    init(...) { ... }
}
```

### `PlanExercise`

```swift
@Model
final class PlanExercise {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var exercise: Exercise?
    var order: Int                          // Drag & Drop
    var restDuration: TimeInterval          // Rest between sets
    var targetRepMin: Int                   // "8-12" → 8
    var targetRepMax: Int                   // "8-12" → 12

    @Relationship(deleteRule: .cascade, inverse: \PlanSet.planExercise)
    var planSets: [PlanSet] = []

    var targetSets: Int { planSets.count }

    init(...) { ... }
}
```

> `order` — целочисленный индекс, при drag&drop пересчитывается batch-обновлением через `WorkoutRepository.reorder(plan:moves:)`.

### `PlanSet`

```swift
@Model
final class PlanSet {
    @Attribute(.unique) var id: UUID
    var planExercise: PlanExercise?
    var order: Int                          // номер сета
    var targetWeight: Double?               // запланированный вес (может быть nil)
    var targetReps: Int

    init(...) { ... }
}
```

### `WorkoutSession`

```swift
@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var title: String                       // "Push Day · Bench focus" | "Quick Workout"
    var plan: WorkoutPlan?                  // nil для Quick Start
    var startedAt: Date
    var finishedAt: Date?
    var totalTonnage: Double

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet] = []

    var isActive: Bool { finishedAt == nil }
    var duration: TimeInterval { (finishedAt ?? .now).timeIntervalSince(startedAt) }
    var containsPR: Bool { sets.contains(where: \.isPersonalRecord) }

    init(...) { ... }
}
```

### `WorkoutSet`

```swift
@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var session: WorkoutSession?
    var exercise: Exercise?
    var setNumber: Int
    var weight: Double
    var reps: Int
    var tonnage: Double                     // weight * reps
    var isPersonalRecord: Bool              // флаг для бейджа PR
    var loggedAt: Date

    init(...) { ... }
}
```

## 3. ModelContainer

```swift
extension ModelContainer {
    static let schemaModels: [any PersistentModel.Type] = [
        UserProfile.self,
        MuscleGroup.self,
        ExerciseMuscle.self,
        Exercise.self,
        PersonalRecord.self,
        WorkoutPlan.self,
        PlanExercise.self,
        PlanSet.self,
        WorkoutSession.self,
        WorkoutSet.self
    ]

    @MainActor
    static func makeProduction() throws -> ModelContainer {
        let schema = Schema(schemaModels)
        let config = ModelConfiguration(
            "FitnesApp",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: AppMigrationPlan.self,
            configurations: [config]
        )
    }

    static func makePreview() throws -> ModelContainer {
        let schema = Schema(schemaModels)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
```

> Enum'ы (`WeightUnit`, `Difficulty`, `Equipment`, `MuscleRole`) — `Codable`, в `Schema` не регистрируются (хранятся как rawValue внутри моделей).

## 4. Repositories

Репозиторий — единственный код с доступом к `ModelContext`. Возвращает доменные модели (если контекст совпадает) или Sendable-DTO (на границе актора).

```swift
protocol ExerciseRepository: Sendable {
    func all() async throws -> [Exercise]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func favorites() async throws -> [Exercise]
    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws
    func find(id: UUID) async throws -> Exercise?
}

@MainActor
final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() async throws -> [Exercise] {
        try context.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)]))
    }

    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise] {
        var predicate: Predicate<Exercise>?
        if !query.isEmpty {
            predicate = #Predicate { $0.name.localizedStandardContains(query) }
        }
        var descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.name)]
        let result = try context.fetch(descriptor)
        guard !muscleGroupIDs.isEmpty else { return result }
        return result.filter { exercise in
            exercise.muscleLinks.contains { link in
                guard let id = link.muscleGroup?.id else { return false }
                return muscleGroupIDs.contains(id)
            }
        }
    }

    func favorites() async throws -> [Exercise] {
        try context.fetch(FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [SortDescriptor(\.name)]
        ))
    }

    func setFavorite(_ exerciseID: UUID, _ value: Bool) async throws {
        guard let exercise = try find(id: exerciseID) else { return }
        exercise.isFavorite = value
        try context.save()
    }

    func find(id: UUID) async throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
```

Аналогично:

- `WorkoutRepository` — `plans()`, `upsert(_:)`, `reorder(plan:moves:)`, `addExercise(_:to:)`, `setPlanSets(_:for:)`, `remove(_:)`, черновики (`isDraft`).
- `SessionRepository` — `activeSession()`, `create(planID:title:)`, `addSet(_:to:)`, `finish(_:at:)`, `history(range:)`, `byID(_:)`.
- `UserRepository` — `current()` (создаёт дефолт при отсутствии), `update(_:)`.

## 5. DTO

Sendable-снимки для пересечения акторов и для UI без живой связи с контекстом.

```swift
struct ExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let difficulty: Difficulty
    let equipment: Equipment
    let isFavorite: Bool
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let animationAssetName: String?
}

struct PlanSetDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let order: Int
    let targetWeight: Double?
    let targetReps: Int
}

struct PlanExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let order: Int
    let restDuration: TimeInterval
    let targetRepMin: Int
    let targetRepMax: Int
    let sets: [PlanSetDTO]
}

struct WorkoutPlanDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String?
    let coverImageName: String?
    let scheduledWeekdays: [Int]
    let totalSets: Int
    let exercises: [PlanExerciseDTO]
}

struct WorkoutSetDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let setNumber: Int
    let weight: Double
    let reps: Int
    let tonnage: Double
    let isPersonalRecord: Bool
    let loggedAt: Date
}

struct WorkoutSessionDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let planName: String?
    let startedAt: Date
    let finishedAt: Date?
    let totalTonnage: Double
    let containsPR: Bool
    let sets: [WorkoutSetDTO]
}
```

## 6. Сидинг каталога

Базовый набор групп мышц и упражнений (с мышечными связями, сложностью, оборудованием) при первом запуске:

```swift
@MainActor
enum DataSeeder {
    static func seedIfNeeded(_ context: ModelContext) throws {
        guard try context.fetchCount(FetchDescriptor<Exercise>()) == 0 else { return }

        // 1. Группы мышц (порядок чипов в Library)
        let groups = MuscleGroupSeed.all.enumerated().map { idx, name in
            MuscleGroup(id: UUID(), name: name, displayOrder: idx)
        }
        groups.forEach(context.insert)
        let byName = Dictionary(uniqueKeysWithValues: groups.map { ($0.name, $0) })

        // 2. Упражнения + ExerciseMuscle (primary/secondary)
        for seed in ExerciseSeed.all {
            let exercise = Exercise(
                id: UUID(),
                name: seed.name,
                descriptionStart: seed.start,
                descriptionExecution: seed.execution,
                descriptionErrors: seed.errors,
                difficulty: seed.difficulty,
                equipment: seed.equipment,
                animationAssetName: seed.asset,
                isFavorite: false
            )
            context.insert(exercise)
            for (muscleName, role) in seed.muscles {
                context.insert(ExerciseMuscle(
                    id: UUID(), role: role,
                    exercise: exercise, muscleGroup: byName[muscleName]
                ))
            }
        }
        try context.save()
    }
}

enum MuscleGroupSeed {
    static let all = ["Chest", "Back", "Legs", "Shoulders", "Arms", "Core"]
}
```

`ExerciseSeed.all` — каталог из 30+ упражнений: для каждого имя, три описания, `difficulty`, `equipment` и список `(мышца, role)`.

## 7. Миграции

```swift
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        UserProfile.self, MuscleGroup.self, ExerciseMuscle.self,
        Exercise.self, PersonalRecord.self,
        WorkoutPlan.self, PlanExercise.self, PlanSet.self,
        WorkoutSession.self, WorkoutSet.self
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [SchemaV1.self]
    static var stages: [MigrationStage] = []
}
```

Правило: каждое изменение схемы — новый `SchemaVN` + `MigrationStage` (lightweight или custom). Существующий `SchemaV*` не править.

## 8. Тестирование Data Layer

- In-memory `ModelContainer` через `ModelContainer.makePreview()`.
- Юнит-тесты репозиториев на пустом контейнере + сидинге фикстур (`Swift Testing`, `@Test`).
- Покрыть: поиск/фильтр по `muscleLinks`, favorites-тоггл, reorder плана и `PlanSet`, создание/финализация сессии + `totalTonnage`, выставление `isPersonalRecord`.
