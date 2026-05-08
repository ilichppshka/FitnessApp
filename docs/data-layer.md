# Data Layer

SwiftData-модели, репозитории, миграции.

## 1. Схема данных

```
MuscleGroup ◇──────────┐
   ▲                   │ many-to-many
   │ many-to-many      │
   │                   ▼
WorkoutPlan ───┬──── Exercise ────► PersonalRecord
               │       ▲
               ▼       │
         PlanExercise  │
                       │
WorkoutSession ────► WorkoutSet
       ▲
       │
   UserProfile (singleton)
```

### Принципы моделирования

- **UUID-идентификаторы.** Каждая сущность имеет `var id: UUID` и `@Attribute(.unique) id`.
- **Cascade delete.** При удалении плана уходят `PlanExercise`. При удалении сессии — её сеты. При удалении упражнения — личные рекорды.
- **Денормализация tonnage.** `WorkoutSet.tonnage = weight * reps`. `WorkoutSession.totalTonnage = sum(sets.tonnage)`. Считается в `WorkoutService` при записи сета и финализации сессии.
- **Inverse relationships** объявляются явно через `@Relationship(inverse:)` для двунаправленных связей.

## 2. Модели

### `MuscleGroup`

```swift
@Model
final class MuscleGroup {
    @Attribute(.unique) var id: UUID
    var name: String

    @Relationship(inverse: \Exercise.muscleGroups)
    var exercises: [Exercise] = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
```

### `Exercise`

```swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionStart: String       // Исходное положение
    var descriptionExecution: String   // Выполнение
    var descriptionErrors: String      // Типичные ошибки
    var animationAssetName: String?    // имя Lottie JSON или .mov

    var muscleGroups: [MuscleGroup] = []

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord] = []

    init(
        id: UUID = UUID(),
        name: String,
        descriptionStart: String,
        descriptionExecution: String,
        descriptionErrors: String,
        animationAssetName: String? = nil
    ) { ... }
}
```

### `PersonalRecord`

```swift
@Model
final class PersonalRecord {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var date: Date
    var weight: Double
    var reps: Int
    var tonnage: Double  // weight * reps, денормализовано

    init(...) { ... }
}
```

### `WorkoutPlan`

```swift
@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetMuscleGroups: [MuscleGroup] = []

    @Relationship(deleteRule: .cascade, inverse: \PlanExercise.plan)
    var planExercises: [PlanExercise] = []

    init(id: UUID = UUID(), name: String) { ... }
}
```

### `PlanExercise`

```swift
@Model
final class PlanExercise {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var exercise: Exercise
    var order: Int
    var targetSets: Int
    var restDuration: TimeInterval

    init(...) { ... }
}
```

> `order` — целочисленный индекс. При drag&drop пересчитывается batch-обновлением через `WorkoutRepository.reorder(plan:moves:)`.

### `WorkoutSession`

```swift
@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var plan: WorkoutPlan?
    var startedAt: Date
    var finishedAt: Date?
    var totalTonnage: Double

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet] = []

    var isActive: Bool { finishedAt == nil }

    init(...) { ... }
}
```

### `WorkoutSet`

```swift
@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var session: WorkoutSession?
    var exercise: Exercise
    var setNumber: Int
    var weight: Double
    var reps: Int
    var tonnage: Double
    var loggedAt: Date

    init(...) { ... }
}
```

### `UserProfile`

```swift
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var bodyWeight: Double
    var selectedMascotId: String
    var restSoundEnabled: Bool
    var restHapticEnabled: Bool

    init(...) { ... }
}
```

> `UserProfile` хранится в единственном экземпляре. Доступ — через `UserRepository.current()`. Если профиль отсутствует — создаётся дефолтный при первом запуске.

## 3. ModelContainer

```swift
extension ModelContainer {
    @MainActor
    static func makeProduction() throws -> ModelContainer {
        let schema = Schema([
            MuscleGroup.self,
            Exercise.self,
            PersonalRecord.self,
            WorkoutPlan.self,
            PlanExercise.self,
            WorkoutSession.self,
            WorkoutSet.self,
            UserProfile.self
        ])
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
        let schema = Schema([...])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
```

## 4. Repositories

Репозиторий — единственный код, имеющий доступ к `ModelContext`. Возвращает либо доменные модели (если контекст совпадает), либо Sendable-DTO (если данные пересекают границу актора).

```swift
protocol ExerciseRepository: Sendable {
    func all() async throws -> [Exercise]
    func search(query: String, muscleGroupIDs: [UUID]) async throws -> [Exercise]
    func find(id: UUID) async throws -> Exercise?
}

@MainActor
final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
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
            exercise.muscleGroups.contains { muscleGroupIDs.contains($0.id) }
        }
    }

    func find(id: UUID) async throws -> Exercise? {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
```

Аналогично:

- `WorkoutRepository` — CRUD планов, `reorder(plan:moves:)`, `addExercise(_:to:)`, `remove(_:)`.
- `SessionRepository` — `activeSession()`, `create(planID:)`, `addSet(_:to:)`, `finish(_:at:)`, `history(range:)`, `byID(_:)`.
- `UserRepository` — `current()`, `update(_:)`.

## 5. DTO

Sendable-снимки для пересечения акторов и для UI без живой связи с контекстом.

```swift
struct ExerciseDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let muscleGroups: [String]
    let animationAssetName: String?
}

struct WorkoutSetDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: UUID
    let exerciseName: String
    let setNumber: Int
    let weight: Double
    let reps: Int
    let tonnage: Double
    let loggedAt: Date
}

struct WorkoutSessionDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let planName: String?
    let startedAt: Date
    let finishedAt: Date?
    let totalTonnage: Double
    let sets: [WorkoutSetDTO]
}
```

## 6. Сидинг каталога

Базовый набор упражнений и групп мышц при первом запуске:

```swift
@MainActor
enum DataSeeder {
    static func seedIfNeeded(_ context: ModelContext) throws {
        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        guard count == 0 else { return }
        let groups = MuscleGroupSeed.all.map { MuscleGroup(name: $0) }
        groups.forEach(context.insert)
        let exercises = ExerciseSeed.makeAll(groups: groups)
        exercises.forEach(context.insert)
        try context.save()
    }
}
```

`ExerciseSeed.makeAll(groups:)` возвращает каталог из 30–50 базовых упражнений с описаниями.

## 7. Миграции

```swift
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        MuscleGroup.self, Exercise.self, PersonalRecord.self,
        WorkoutPlan.self, PlanExercise.self,
        WorkoutSession.self, WorkoutSet.self, UserProfile.self
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [SchemaV1.self]
    static var stages: [MigrationStage] = []
}
```

Правило: каждое изменение схемы — новый `SchemaVN` + `MigrationStage` (lightweight или custom). Никогда не править существующий `SchemaV*`.

## 8. Тестирование Data Layer

- In-memory `ModelContainer` через `ModelContainer.makePreview()`.
- Юнит-тесты репозиториев на пустом контейнере + сидинге фикстур.
- Использование `Swift Testing`: `@Test` функции принимают свежий контекст через фикстуру.
