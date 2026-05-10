# UI Components Catalog

Каталог базовых компонентов, из которых строится UI приложения. Составлен на основе референс-скринов в [../screens/](<../screens/>):
[Dashboard](<../screens/Dashboard.png>) ·
[Workout builder](<../screens/Workout builder.png>) ·
[Exercise library](<../screens/Exercise library.png>) ·
[Active workout](<../screens/Active workout.png>) ·
[Progress and analytics](<../screens/Progress and analytics.png>) ·
[Settings and profile](<../screens/Settings and profile.png>).

Используется как словарь для Фаз 4–11 [roadmap.md](roadmap.md): прежде чем верстать новый экран — посмотреть, какие части уже есть, а какие нужно добавить.

Маркеры статуса:
- `✅` — компонент уже реализован в коде
- `🟡` — частично есть базис (нужны вариации)
- `⬜️` — ещё не реализован

---

## 1 · Foundations

Не компоненты, а токены. Уже задокументированы — здесь только сводка.

| Слой | Файл | Что в нём |
|---|---|---|
| Цвета | [Colors.swift](<../FitnesApp/DesignSystem/Tokens/Colors.swift>) | `surface`, `surfaceContainerLow/High`, `primary`, `onPrimary`, `onSurface`, `outlineVariant` |
| Типографика | [Typography.swift](<../FitnesApp/DesignSystem/Tokens/Typography.swift>) | `displayLg`, `headlineLg`, `titleLg`, `bodyMd`, `labelSm` |
| Отступы | [Spacing.swift](<../FitnesApp/DesignSystem/Tokens/Spacing.swift>) | `xxs · xs · sm · md · lg · xl · xxl` |
| Радиусы | [Radii.swift](<../FitnesApp/DesignSystem/Tokens/Radii.swift>) | `sm · md · lg · pill` |
| Тема | [Theme.swift](<../FitnesApp/DesignSystem/Theme.swift>) | `kineticTheme()` корневой modifier, `.preferredColorScheme(.dark)` |

Эффекты: `NeonGlowModifier` (`.neonGlow()`) — двухслойный drop-shadow primary, применяется к CTA, активной анимации маскота и кружку плей-кнопки. ✅

---

## 2 · Primitives (атомы)

Минимальные строительные блоки. У большинства одна ответственность и нет внутренней иерархии.

### 2.1 KineticButton ✅
Pill-кнопка. Высота 56, радиус `md`, шрифт `titleLg`.
- **primary** — заливка `primary`, текст `onPrimary`, neon glow. Используется для финального CTA («Start Workout», «Save Plan ›», «Complete Set»).
- **secondary** — outline `outlineVariant`, текст `onSurface`. Не встречается в текущих скринах, но запланировано.
- **disabled** — opacity 0.4, без glow.
- **with-trailing-icon** — вариант с символом справа (chevron у «Save Plan ›», галка у «Complete Set»). ✅

### 2.2 IconChip ✅
Круглый «таблеточный» элемент 40×40 для иконок навигации/действий. Заливка `surfaceContainerHigh`, тонкий outline `outlineVariant.opacity(0.3)`.
- Везде в TopBar: back arrow, close (×), more (⋯), download (↓).
- Используется и без действия — как контейнер иконки в SettingsRow слева.

### 2.3 TextButton ✅
Чистый текст без фона в `Color.App.primary`. Используется для второстепенных действий: «Edit» в Settings, «This week ↑» в графике, «Sort» в Library.
Опциональный вариант с pill-фоном `surfaceContainerHigh` (Workout builder → «Save Draft»).

### 2.4 Chip / Pill ✅
Капсульный тег с текстом. 4 варианта:
| Вариант | Заливка | Текст | Где |
|---|---|---|---|
| `.selected` | `primary` | `onPrimary` | активный фильтр «All 258», активный диапазон «Month» |
| `.outline` | прозрачная + outline | `onSurface` | неактивные фильтры мышечных групп |
| `.subtle` | `surfaceContainerHigh` | `onSurface.opacity(0.7)` | мета-теги «TODAY · WEEK 3», «4 LEFT», quick-adjust «-15s / +15s / Skip» |
| `.delta` | `primary.opacity(0.15)` | `primary` | «↑ +18.2%», «↑ +5kg», «↑ +2», «↑ +1h» |

Опциональный leading-glyph (стрелка ↑ в delta, точка-индикатор в `LIVE`).

### 2.5 Badge ✅
Маленький квадратный/круглый индикатор. Цифра упражнения в порядке (зелёный кружок «1» в Workout builder), счётчик «4 LEFT» (это уже chip subtle). Размер ~24×24.

### 2.6 StatusDot ✅
Закрашенный кружок 6–8pt + опциональная пульсация. «● LIVE» в Active workout, «● Auto-saved» в Workout builder. Цвет `primary`.

### 2.7 ToggleSwitch ✅
Реализован как `KineticToggle` — тонкая обёртка над `Toggle` со стилем `.tint(Color.App.primary)`. Settings → «Auto-start rest timer».

### 2.8 StepperButton ✅
Круглая кнопка 44×44 с символом `minus`/`plus`. Заливка `surfaceContainerHigh`, нажатие даёт haptic. Используется в SetInputPanel (Active workout).

### 2.9 GhostInputField ✅
Текстовое поле с подчёркиванием, реагирующим на focus (1pt → 2pt primary). Используется как:
- свободное поле имени (Settings),
- крупный numeric input (вес/повторы) с `suffix`.

### 2.10 SearchField ✅
Pill-инпут, высота 44, заливка `surfaceContainerHigh`, leading magnifier, trailing meta-count («3K» в Library). Поверх — обычный `TextField` без подчёркивания.

### 2.11 SectionLabel ✅
Текст в `Font.App.labelSm`, uppercase, `onSurface.opacity(0.5)`. Везде над секциями: «NEXT SESSION», «THIS WEEK», «TRAINING», «LIBRARY», «PROFILE» и т.д.

### 2.12 ScreenHeader ✅
Композит `SectionLabel` + `headlineLg`. Опционально цветной счётчик в primary справа от заголовка («Exercises 258»).

### 2.13 AvatarCircle ✅
Круг с инициалом или фото. Размеры `sm` (32, в TopBar Dashboard), `lg` (72, в ProfileCard). Опциональный edit-overlay (мелкий primary chip с pencil/back-arrow).

### 2.14 ProgressDots ✅
Горизонтальный ряд точек, активная — primary, остальные `outlineVariant`. Active workout, под названием упражнения («Set 3 of 4» = 3 ярких из 4).

### 2.15 ProgressRing ✅
Круговой индикатор с числом внутри. Dashboard: «3/5 SESSIONS» — кольцо primary на фоне dimmed-track.

---

## 3 · Composites (молекулы)

Собираются из примитивов; имеют собственную семантику.

### 3.1 TopBar ⬜️
Унифицированная шапка экрана: leading IconChip + опциональный центр-title + trailing (IconChip / TextButton / KineticButton-mini). Sticky, прозрачный фон или blur при скролле.

### 3.2 StatTriple ⬜️
Три равные колонки `value / LABEL`. Используется минимум на трёх экранах:
- Dashboard hero — «6 EXERCISES / 45 MIN / 22 SETS»
- Workout builder header — «5 / 48 min / 18»
- ProfileCard — «78kg / 182cm / 3 LEVEL»

Параметры: список из 1..N пар (`value`, `unit?`, `label`).

### 3.3 StatTile ⬜️
Карточка-плитка для аналитики (Progress): leading IconChip, label, value (`headlineLg`), delta-chip в углу. Сетка 2 колонки.

### 3.4 DeltaPill ⬜️
Уже есть как Chip variant `.delta`, но обычно живёт рядом с метрикой и принимает `(arrow, percent, comparison: String?)`. Можно сделать convenience-инициализатор.

### 3.5 WeekCalendarStrip ⬜️
Горизонтальный ряд из 7 DayCell. Активный день — заливка primary, текст onPrimary; прошедший — text dimmed. Snap к текущему дню при появлении.

### 3.6 DayCell ⬜️
Один день: weekday letter (`labelSm` opaque-50%) + число (`titleLg`). Состояния: `.past`, `.today`, `.future`.

### 3.7 RangeTabs ⬜️
Сегментированный пилл со списком вариантов. Progress: «Week / Month / 3M / Year / All». Активный — outline pill, остальные — текст без фона.

### 3.8 SettingsRow ⬜️
Унифицированная строка списка настроек: leading IconChip + title + trailing slot (text-value / Chip / ToggleSwitch). Высота 56, разделитель — `outlineVariant.opacity(0.2)`.

### 3.9 SettingsGroup ⬜️
Контейнер вокруг N SettingsRow с общим SectionLabel сверху. Карточный фон `surfaceContainerLow`, радиус `md`.

### 3.10 ExerciseListItem ⬜️
Строка библиотеки: leading thumbnail (квадрат `sm`-радиус с play-glyph поверх) + title + subtitle (мышцы) + меta (PR/вес) + trailing «+» IconChip.
Варианты:
- recent / list — компакт
- featured — крупная карточка с анимацией (см. 3.11)

### 3.11 FeaturedExerciseCard ⬜️
Большая карточка «Exercise of the day»: leading section label + filename meta-tag, центральный title `headlineLg`, мышцы подзаголовком, trailing большая круглая play-кнопка primary с neon glow.

### 3.12 NextWorkoutCard ⬜️
Hero-карточка Dashboard: subtle-chip («TODAY · WEEK 3»), micro-label («MUSCLE FOCUS»), title `headlineLg` («Back Day»), диагональный beam-эффект, embedded StatTriple, ряд outline Chip с мышцами, primary KineticButton «Start Workout». Радиус `lg`, фон `surfaceContainerHigh`.

### 3.13 WeeklyStatsCard ⬜️
PerformanceCard со встроенным ProgressRing слева и блоком «TOTAL VOLUME · 18,420 kg» справа.

### 3.14 ChartCard ⬜️
PerformanceCard, внутри: top-row (label слева, TextButton-deltatab справа) + текущее значение `displayLg` + Swift Charts area-chart с axis-метками месяцев. Реализуется на `Charts` фреймворке.

### 3.15 SetRow ⬜️
Строка в таблице сетов Workout builder: index | WEIGHT cell | REPS cell | × remove.

### 3.16 SetCell ⬜️
Inline-инпут с числом + единицей. Тонкий border `outlineVariant`, при focus переходит в `primary`. Используется в SetRow и SetInputPanel.

### 3.17 ExerciseBuilderCard ⬜️
Раскрывающаяся карточка упражнения в Workout builder: header (Badge + title + chevron) + N SetRow + «+ Add set» TextButton + RestRow («REST BETWEEN SETS · 02:00»). В свёрнутом состоянии: header + trailing meta «4 × 10–12».

### 3.18 RestRow ⬜️
Узкая полоса внутри ExerciseBuilderCard или внизу Active workout: leading timer-glyph + label + trailing time. Тачабельна (открывает picker).

### 3.19 SetInputPanel ⬜️
Двухколоночная панель Active workout: для каждой колонки — column-label + DeltaPill + value `displayLg` + горизонтальный ряд `Stepper - / + `. На минусе/плюсе haptic.

### 3.20 RestTimerBar ⬜️
Полоса под Active workout CTA: leading label «REST · NEXT SET IN», trailing крупный таймер `displayLg`. Под ней — ряд subtle Chip «-15s / +15s / Skip».

### 3.21 BottomActionDock ⬜️
Закреплённая снизу полоса (Workout builder, Active workout): summary-text слева + primary KineticButton справа. Прозрачный gradient-фон поверх контента.

### 3.22 MascotStage ⬜️
Главный медиа-блок Active workout: квадрат с заливкой `primary` + Lottie/MOV анимация поверх + статус-Chip в углу `LIVE · TECHNIQUE`, filename meta. Снизу TimelineScrubber. Радиус `lg`, neon glow при `.active`.

### 3.23 TimelineScrubber ⬜️
Лента воспроизведения внутри MascotStage: время начала + ползунок + текущее время + speed-Chip («1.0×»). Жесты scrubbing.

### 3.24 ProfileCard ⬜️
Карточка пользователя в Settings: AvatarCircle (с edit-overlay) + name `titleLg` + secondary line (email · member since) + StatTriple. Фон `surfaceContainerLow`, радиус `md`.

### 3.25 MascotCard ⬜️
Settings: квадратный preview с neon-glow + label «YOUR MASCOT» + title-bold `Athlete · Default` + caption «Tap to change character» + counter Chip «4 LEFT». Тачабельна → MascotPicker.

### 3.26 PerformanceCard ✅
Базовый контейнер-обёртка для всех карточек. Уже реализован: surface-container-high, радиус `md`, опциональный action.

### 3.27 FloatingNavPill ✅
Стеклянный bottom-таб с 5 пунктами. Уже реализован, через `matchedGeometryEffect`.

---

## 4 · Mapping: компонент → экран

Какие из перечисленных компонентов нужны на каждом экране. Помогает планировать порядок реализации в фазах 4–10.

### Dashboard
TopBar (avatar) · ScreenHeader («Hey, Alex») · WeekCalendarStrip · SectionLabel · NextWorkoutCard (= subtle Chip + StatTriple + outline Chip × N + KineticButton) · WeeklyStatsCard (= ProgressRing + value) · FloatingNavPill.

### Workout builder
TopBar (back + Save Draft TextButton) · ScreenHeader + StatusDot · StatTriple · SectionLabel · ExerciseBuilderCard × N (Badge + SetRow + RestRow + AddSet TextButton) · BottomActionDock.

### Exercise library
TopBar (back + filter IconChip) · ScreenHeader («Exercises 258») · SearchField · Chip-row (мышцы) · FeaturedExerciseCard · SectionLabel · ExerciseListItem × N · trailing TextButton «Sort» · FloatingNavPill.

### Active workout
TopBar (close + center timer + more) · MascotStage + TimelineScrubber · ProgressDots · meta SectionLabel + title `headlineLg` + subtitle · SetInputPanel × 2 колонки · KineticButton primary («Complete Set») · RestTimerBar.

### Progress
TopBar (back + download IconChip) · ScreenHeader · RangeTabs · big metric block (label + `displayLg` + DeltaPill) · ChartCard · StatTile × 2 (sessions / time) · далее «NEW PRS / STREAK» сетка StatTile · FloatingNavPill.

### Settings
TopBar (back + Edit TextButton) · ScreenHeader · ProfileCard · MascotCard · SettingsGroup (TRAINING) с SettingsRow × N (где trailing = value, Chip или ToggleSwitch) · SettingsGroup (NOTIFICATIONS & FEEDBACK) · FloatingNavPill.

---

## 5 · Definition of Done для нового компонента

- Файл в [FitnesApp/DesignSystem/Components/](<../FitnesApp/DesignSystem/Components/>), один компонент = один файл.
- API через инициализатор + `@ViewBuilder` content там, где имеет смысл (как `PerformanceCard`).
- Использует только токены из `Colors.App / Font.App / Spacing / Radii`. Хардкод значений — повод вынести в токен.
- `#Preview` минимум с дефолтным состоянием; для интерактивных — со всеми состояниями (focus, pressed, disabled).
- Включён в [ComponentCatalog](<../FitnesApp/DesignSystem/ComponentCatalog.swift>) под `#if DEBUG`.
- Swift 6 strict concurrency: компонент `MainActor` по умолчанию, без warnings.
- Соответствует [design-system.md](design-system.md) (если есть конфликт — обновляется design-system, а не код).
