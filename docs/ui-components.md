# KINETIC — UI Components Catalog

Каталог дизайн-системы **Kinetic Laboratory** и компонентов UI, извлечённых из реальных макетов в [app-design/design-claude-code/](app-design/design-claude-code/) (`dashboard.jsx`, `library.jsx`, `builder.jsx`, `active.jsx`, `progress.jsx`, `settings.jsx`). Каноничный источник токенов — объект `K` в [dashboard.jsx](app-design/design-claude-code/dashboard.jsx).

> **Связь с другими доками:** экраны и навигация — [userflow.md](userflow.md); модели — [models.md](models.md); сервисы — [services-and-repository.md](services-and-repository.md); порядок реализации — Фаза 3 в [roadmap.md](roadmap.md). Этот файл — словарь визуального слоя: токены → примитивы → композиты → правила.
>
> Целевая структура кода — `FitnesApp/DesignSystem/{Tokens,Components}` (один компонент = один файл). **Dark Mode Only.**

---

## 1. Design Tokens

### 1.1. Цвета

Точные значения из макета (`K`). Четыре «этажа» поверхности задают иерархию карточек: чем выше элемент, тем светлее фон.

| Токен | HEX / значение | Назначение |
| --- | --- | --- |
| `surface` | `#0e0f0c` | фон экрана (корень) |
| `surfaceLow` | `#131410` | карточки, поля, утопленные блоки |
| `surfaceHigh` | `#1f201c` | приподнятые карточки, icon-кнопки, hero |
| `surfaceHighest` | `#2a2b26` | верхний слой (off-состояние тумблера, аватар-паттерн) |
| `primary` | `#d3f670` (lime) | акцент: CTA, активное состояние, позитивная дельта |
| `onPrimary` | `#131a00` | текст/иконки на lime |
| `onSurface` | `#f5f4ee` | основной текст |
| `onSurfaceMuted` | `#8a8a82` | вторичный текст, лейблы, единицы |
| `danger` | `#ff6e6e` | деструктивные действия (Clear, Sign out) |
| `live` | `#ff5e5e` | индикатор LIVE на Active Workout |

**Производные (translucent / overlay):**

| Назначение | Значение |
| --- | --- |
| lime-подложка тегов/иконок | `rgba(211,246,112,0.10–0.15)` |
| lime-«призрак» (Add Exercise fill) | `rgba(211,246,112,0.04)` |
| neon-glow lime | `rgba(211,246,112,0.35–0.5)` |
| стекло поверх изображений | `rgba(14,15,12,0.6)` + blur |
| фон плавающего таб-бара | `rgba(42,43,38,0.7)` + blur |
| текст/линии на изображении | `rgba(245,244,238, 0.6 / 0.4 / 0.3 / 0.2 / 0.12 / 0.08)` |

```swift
// DesignSystem/Tokens/Colors.swift — Color.App.*
enum App {
    static let surface = Color(hex: 0x0E0F0C)
    static let surfaceLow = Color(hex: 0x131410)
    static let surfaceHigh = Color(hex: 0x1F201C)
    static let surfaceHighest = Color(hex: 0x2A2B26)
    static let primary = Color(hex: 0xD3F670)
    static let onPrimary = Color(hex: 0x131A00)
    static let onSurface = Color(hex: 0xF5F4EE)
    static let onSurfaceMuted = Color(hex: 0x8A8A82)
    static let danger = Color(hex: 0xFF6E6E)
}
```

### 1.2. Типографика

Два семейства: **Space Grotesk** (display и **все цифры**) и системный **SF Pro** (весь UI-текст и лейблы). Тех-теги (`[mascot · bench_press.lottie]`, версия в футере) — **SF Mono** (моноширинный из семейства SF). SF Pro / SF Mono — системные (бандлить не нужно), бандлим только Space Grotesk; сторонних шрифтов (Inter и т.п.) в проекте нет.

| Роль | Шрифт | Размер · вес | Где |
| --- | --- | --- | --- |
| `displayXl` | Grotesk | 56 / 700 · `-0.03em` | Progress hero (`72,840`) |
| `displayLg` | Grotesk | 48 / 700 · `-0.03em` | Active input value (`75`) |
| `displayMd` | Grotesk | 40–44 / 700 · `-0.02em` | заголовки экранов (Library 44; Builder/Progress/Settings 40) |
| `displaySm` | Grotesk | 36 / 700 · `-0.02em` | Dashboard hero (`Back Day`) |
| `headlineLg` | Grotesk | 32 / 700 · `-0.02em` | rest-таймер, Total Volume |
| `headlineMd` | Grotesk | 28 / 700 | greeting, заголовок упражнения, `Stat.value` |
| `headlineSm` | Grotesk | 24–26 / 700 | featured, Latest PR, StatTile, SummaryStat |
| `titleLg` | Grotesk | 22 / 700 | центр кольца, дата истории, имя профиля, маскот |
| `titleMd` | Grotesk | 16–18 / 600 | число дня, таймер сессии, SetField |
| `bodyMd` | SF Pro | 14 / 500–600 | основной UI-текст, строки |
| `bodySm` | SF Pro | 12–13 / 500 | подписи, мышцы, единицы |
| `label` | SF Pro | 11 / 700 · `0.08em` UPPER | секции (`THIS WEEK`, `LIBRARY`) |
| `labelSm` | SF Pro | 9–10 / 700 · `0.1–0.12em` UPPER | микро-лейблы (`SET`, `EXERCISE 2 OF 5`) |

**Правила цифр:** таймеры, тоннаж, веса/повторы — всегда Space Grotesk + `tabular-nums` (`fontVariantNumeric`), чтобы цифры не «прыгали». Единица (`kg`, `min`, `reps`) — SF Pro, muted, мельче основного числа.

### 1.3. Отступы и раскладка

| Токен | Значение | Назначение |
| --- | --- | --- |
| screen H-padding | **20** | стандартные боковые поля контента |
| status-bar inset | **58** (`paddingTop`) | под Dynamic Island |
| nav clearance | **140** (Active — **200**) | нижний `paddingBottom` под плавающий бар |
| section gap | 22–28 | между крупными блоками |
| card padding | 16–20 | внутренние поля карточек |
| item gap | 8–12 | между строками списков/карточек |
| spacing scale | `xxs 4 · xs 6 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24` | сетка значений из макета |

### 1.4. Радиусы

Из макета (диапазон 8–32). Семантический набор:

| Токен | px | Применение |
| --- | --- | --- |
| `pill` | 999 | таб-бар, чипсы, glass-pill, CTA в bottom-доках |
| `xxl` | 28–32 | hero-карта, mascot canvas, Active bottom dock |
| `xl` | 24 | QuickStats, Settings/Featured/Chart карточки |
| `lg` | 20–22 | CTA Dashboard, exercise-строки, InputBlock, avatar |
| `md` | 16–18 | search, history row, Builder card, SettingsGroup, StatTile |
| `sm` | 12–14 | range-tabs, rest-pill, степперы, нижние кнопки, thumb |
| `xs` | 8–10 | SetField, icon-chip (Settings), index-badge |
| `tag` | 4–6 | мелкие теги (`Cable`, `PR`) |

### 1.5. Высота, glow и стекло

- **Иерархия карточек** через 4 этажа поверхности (`surface → surfaceLow → surfaceHigh → surfaceHighest`) вместо теней. Тени — только у плавающих элементов.
- **Neon glow** (`NeonGlowModifier`, `.neonGlow()`): `drop-shadow(0 0 16px rgba(211,246,112,0.35))` для CTA; усиленный `0.5` — на `Complete Set`; точечные `0 0 6–10px` — на маркерах/кольце/точках статуса.
- **Glass** (плавающий бар, пилюли поверх изображений): `backdrop blur(20–25px) saturate(180%)`, фон `rgba(42,43,38,0.7)` (бар) / `rgba(14,15,12,0.6)` (пилюля), плюс у бара `box-shadow 0 16px 32px rgba(211,246,112,0.08)` + `inset 0 0 0 0.5px rgba(211,246,112,0.1)`.
- **Изображения-плейсхолдеры**: диагональные `repeating-linear-gradient` полосы + mono-тег в углу (`[hero_image · deadlift_hero.jpg]`).

### 1.6. Иконки и движение

- Иконки — тонкие SVG `strokeWidth 1.4–2`, `currentColor` (наследуют состояние). В iOS-реализации — **SF Symbols 6** с анимацией для таб-бара.
- **StatusDot** — пульсация (`@keyframes pulse`, opacity 1↔0.4, 1.4s) для LIVE / Auto-saved.
- **CTA shimmer** — диагональный световой блик по `Complete Set` при логировании (вместе с хаптиком).
- Переходы фона/раскрытия — `~0.15s`.

```swift
// DesignSystem/Tokens — Spacing.swift · Radii.swift · Typography.swift
// + Theme.swift (kineticTheme(): .preferredColorScheme(.dark), фон surface, шрифты)
```

---

## 2. Components

Один компонент = один файл в `DesignSystem/Components/`. Параметры — через инициализатор; контент — `@ViewBuilder` где уместно. Только токены, без хардкода.

### 2.1. Primitives (атомы)

| Компонент | Спецификация | Источник |
| --- | --- | --- |
| **SectionLabel** | UPPER, SF Pro 11/700, `0.08em`, muted. Базовый ритм над секциями. | везде (`KLabel`) |
| **StatNumber** | Большое число Grotesk + опц. unit-суффикс (SF Pro, muted, мельче). `tabular-nums`. | `Stat`, `SummaryStat`, `ProfileStat` |
| **IconButton** | Круг 40×40, `surfaceHigh`, тонкая иконка по центру. Варианты: back / close / more (⋯) / filter / download. | TopBar всех экранов |
| **PrimaryButton** (`KineticButton`) | Заливка `primary`, текст `onPrimary` 700, neon glow, опц. trailing-иконка (chevron / play / check). Высоты 50–64. | Start Workout, Save Plan, Complete Set |
| **FilterChip** | Пилюля: активная — `primary`+glow, неактивная — `surfaceLow`. Опц. count-суффикс. | Library фильтры, RangeTabs |
| **MuscleTag** | Пилюля `surfaceLow`, muted-текст 12. | hero target muscles |
| **EquipmentTag** | Мелкий UPPER-тег `primary` на `rgba(211,246,112,0.12)`, r4. | Library (`Cable`, `Barbell`) |
| **GlassPill** | Полупрозрачная blur-пилюля с опц. StatusDot (`TODAY · WEEK 3`, `LIVE · TECHNIQUE`). | Dashboard hero, Active mascot |
| **DeltaBadge** | `↑ +18.2%` lime на `rgba(211,246,112,0.12)` либо просто `↑ +2`. Знак/стрелка = семантика. | Progress, QuickStats, StatsGrid, InputBlock |
| **CounterChip** | UPPER lime-пилюля счётчика (`4 LEFT`). | Settings mascot |
| **PRBadge** | Крошечный `PR` lime на translucent, r4. | Library row, History row |
| **StatusDot** | Кружок 6–8 + glow + опц. пульс. Lime / red(`live`). | LIVE, Auto-saved, notif-dot |
| **KineticToggle** | 36×22 пилюля, on = `primary`+glow, ручка `onPrimary`. | Settings тумблеры |
| **StepperButton** | Кнопка `surfaceHigh` (h36 / 44×44), `− / +`, haptic на тап. | Active InputBlock |
| **ProgressDots** | Ряд точек: filled lime+glow vs muted. | Active (`Set 3 of 4`) |
| **ProgressRing** | SVG-кольцо `primary` на dimmed-track + число в центре (`3/5`). | Dashboard QuickStats |
| **DifficultyBars** | 3-полосный индикатор (Beginner=1 … Advanced=3), цвет по уровню. | Library row |
| **SearchField** | Пилюля `surfaceLow`: лупа + placeholder + trailing `⌘K`-бейдж. | Library |
| **SetField** | Inline-ячейка: число Grotesk + unit, утопленный фон. | Builder set-row, Active |
| **Avatar** | Круг с инициалом; опц. notif-dot или edit-pip (lime). Размеры 32/44/64/72. | Dashboard, Settings |
| **MonoTag** | `SF Mono` тех-тег в `[…]` / версия. | hero, mascot, footer |
| **FrameTag** | Мелкий Grotesk-тег на blur (`0:00`, `1.0×`). | Active mascot timeline |
| **ChevronRight** | Disclosure-индикатор, opacity 0.3. | строки-списки |

### 2.2. Composites (молекулы)

| Компонент | Состав / поведение | Экран |
| --- | --- | --- |
| **DashboardTopBar** | eyebrow-дата + greeting (Grotesk 28) + Avatar с notif-dot. | Dashboard |
| **ScreenHeader** | back IconButton + trailing (action/IconButton) + eyebrow SectionLabel + крупный тайтл + опц. lime-счётчик (`Exercises 258`). | Library/Builder/Progress/Settings |
| **WeekStrip** + **DayCell** | 7 ячеек; состояния `done` (точка-маркер) / `today` (lime+glow) / `planned` / `rest` (muted). | Dashboard |
| **NextWorkoutCard** (Hero) | cover-плейсхолдер + GlassPill + eyebrow + тайтл + StatRow (`6 ex · 45 min · 22 sets`) + MuscleTag×N + PrimaryButton `Start Workout`. r28. | Dashboard |
| **StatRow** | 1..N колонок `value/unit + LABEL`. | hero, ProfileCard |
| **QuickStatsCard** | ProgressRing (слева) + `TOTAL VOLUME` + DeltaBadge. | Dashboard |
| **QuickActionCard** | Мини-карточка: icon-плашка + title + subtitle (`Quick Start / Empty workout`; `Latest PR`). | Dashboard SecondaryRow |
| **FilterChipsRow** | Горизонтальный скролл FilterChip. | Library |
| **FeaturedExerciseCard** | «Exercise of the Day»: cover + StatusDot-eyebrow + тайтл + мышцы + круглая play-кнопка `primary`+glow. r24, h156. | Library |
| **ExerciseRow** | thumb(play, опц. featured-dot) + name + EquipmentTag + мышцы + DifficultyBars + PRBadge + add-IconButton(`+`). | Library, Add-Exercise |
| **SectionHeaderRow** | SectionLabel + count + опц. action-ссылка (`Sort`, `View all`). | Library, Progress |
| **BuilderSummaryCard** | 3× SummaryStat (`EXERCISES / EST. TIME / TOTAL SETS`). | Builder |
| **BuilderExerciseCard** | drag-handle + index-badge + name/мышцы; **collapsed**: компакт `4 × 8` + chevron; **expanded**: таблица сетов + AddSet + RestPill. Фон меняется `surfaceLow↔High`. | Builder |
| **SetEditorRow** | grid `SET / WEIGHT / REPS / ×`: номер + 2× SetField + remove. | Builder (expanded) |
| **AddSetButton** | Пунктирная строка `+ Add set`. | Builder |
| **RestPill** | timer-glyph + `Rest between sets` + время (Grotesk, tabular). Тачабельна → picker. | Builder, Active |
| **AddExerciseButton** | Крупная пунктирная lime-кнопка с `+`-плашкой. | Builder |
| **BottomActionDock** | Плавающая пилюля: summary слева + PrimaryButton справа (`Save Plan`). | Builder |
| **MascotCanvas** | Медиа-блок: gradient+scan-lines фон, фигура/Lottie, GlassPill `LIVE`, MonoTag ассета, ряд FrameTag. r28, h240. | Active |
| **ActiveExerciseInfo** | eyebrow `EXERCISE n OF m` + тайтл + ProgressDots + строка `Set x of y · Last set: 70kg × 10`. | Active |
| **InputBlock** | label + опц. DeltaBadge (`↑ +5kg`) + крупное value(48) + unit + ряд StepperButton. | Active (Weight/Reps) |
| **CompleteSetButton** | CTA `primary` h64: check + `Complete Set` + `75 × 8`, glow + shimmer. | Active |
| **RestTimerBar** | Плавающий dock: пульс-StatusDot + `REST · NEXT SET IN` + крупный таймер(32, lime, glow) + progress-bar + ряд `−15s / +15s / Skip`. r32. | Active |
| **RangeTabs** | Сегмент-контрол `Week/Month/3M/Year/All`, активный — `surfaceHigh`+тонкий lime-stroke. | Progress |
| **HeroMetric** | eyebrow + огромное число(56) + unit + DeltaBadge + «vs previous». | Progress |
| **VolumeChart** | Карточка: header + текущее значение + area-chart (lime line+gradient, glow last-point) + ось месяцев. На iOS — **Swift Charts**. | Progress |
| **StatTile** + **StatsGrid** | Плитка: icon-chip + DeltaBadge + LABEL + value/unit. Сетка 2×2 (`Sessions/Time/New PRs/Streak`). | Progress |
| **HistoryRow** | date-блок + name + опц. PRBadge + `dur · vol · sets` + chevron. → Session Detail. | Progress |
| **ProfileCard** | Avatar(64, edit-pip) + имя + `email · member since` + StatRow (`WEIGHT/HEIGHT/LEVEL`). | Settings |
| **MascotPreviewCard** | mascot-thumb(glow) + `YOUR MASCOT` + имя + caption + CounterChip. → Mascot Picker. | Settings |
| **SettingsGroup** + **SettingsRow** | Группа с SectionLabel + строки: icon-chip + label + (value / KineticToggle / chevron). Danger-вариант (красный). | Settings |
| **FloatingNavBar** | Стеклянный таб-бар, активный пункт — lime + подсветка-пилюля. **4 таба** (см. ниже). | все табы |
| **VersionFooter** | MonoTag по центру (`KINETIC v1.0.4 · build …`). | Settings |

> **⚠️ Таб-бар — расхождение с макетом.** В jsx плавающий бар нарисован с **5 слотами**, а центр непоследователен (`Train` на Dashboard/Library, `Progress` на Progress/Settings). Следуем решению из [userflow.md](userflow.md#1-навигация-и-структура): **4 таба** — Home · Library · Progress · Profile. `Train` (Start/Quick Start) и Builder — **не табы**, а действия/полноэкранные экраны с Home. `FloatingNavBar` реализуем на 4 пункта.

---

## 3. Компонент → экран

| Экран | Ключевые композиты |
| --- | --- |
| **Onboarding** | ProgressDots · PrimaryButton · SectionLabel · (Skip как text-action) |
| **Profile Setup** | ScreenHeader · GhostInputField(имя) · SetField+unit-toggle(вес) · MascotPickerGrid · PrimaryButton |
| **Dashboard** | DashboardTopBar · WeekStrip · NextWorkoutCard · QuickStatsCard · QuickActionCard×2 · FloatingNavBar |
| **Library** | ScreenHeader(+count) · SearchField · FilterChipsRow · FeaturedExerciseCard · SectionHeaderRow · ExerciseRow×N · FloatingNavBar |
| **Exercise Detail** (sheet) | MascotCanvas · MuscleTag(prim/sec) · RangeTabs(`Technique/PRs/History`) · PR-карточка(Est.1RM/Attempts) · StatusDot · PrimaryButton(`Add to Workout`)+⭐ |
| **Workout Builder** | ScreenHeader+StatusDot(Auto-saved) · BuilderSummaryCard · BuilderExerciseCard×N (SetEditorRow + AddSetButton + RestPill) · AddExerciseButton · BottomActionDock |
| **Active Workout** | ActiveTopBar(timer) · MascotCanvas · ActiveExerciseInfo · InputBlock×2 · CompleteSetButton · RestTimerBar |
| **Progress** | ScreenHeader · RangeTabs · HeroMetric · VolumeChart · StatsGrid · SectionHeaderRow · HistoryRow×N · FloatingNavBar |
| **Session Detail** | ScreenHeader · ExerciseRow(read-only) · SetEditorRow(read-only) · StatRow(итоги) |
| **Settings** | ScreenHeader · ProfileCard · MascotPreviewCard · SettingsGroup×4 (TRAINING/NOTIFICATIONS/DATA/ACCOUNT) · VersionFooter · FloatingNavBar |

---

## 4. Guidelines & UX Patterns

1. **Dark only.** Один режим; `Theme` форсирует `.preferredColorScheme(.dark)`. Светлой палитры нет.
2. **Lime — дефицитный ресурс.** `primary` только для: главный CTA экрана, активное состояние (таб/фильтр/день), позитивная дельта, маркеры PR/LIVE. Не заливать им крупные поверхности — иначе теряется акцент.
3. **Иерархия через поверхности, не тени.** Глубина = переход по этажам `surface→…→surfaceHighest`. Тени/glow приберечь для плавающих элементов и акцента.
4. **Цифры — это бренд.** Все метрики, таймеры, веса — Space Grotesk + `tabular-nums`, отрицательный трекинг на крупных. Единицы — SF Pro, muted, мельче.
5. **Ритм «лейбл → число».** Секция = UPPER SectionLabel сверху + крупное Grotesk-значение. Держать единообразно на всех экранах.
6. **Управление одной рукой (Active Workout).** Крупные tap-зоны: CTA 56–64, степперы 44, поля ввода большие. Критичные действия — в нижней половине.
7. **Floating pill везде.** Таб-бар и нижние доки (Builder/Active) — плавающие стеклянные пилюли у нижнего края (inset 14, bottom 18–22), контент получает нижний паддинг 140 (Active — 200).
8. **Стекло поверх контента.** Любая пилюля над изображением/маскотом — blur + полупрозрачный фон, не сплошная заливка.
9. **Статус — точкой.** Живые состояния (LIVE, Auto-saved, today, notif) — StatusDot + glow, активные — пульс.
10. **Haptics + shimmer.** `Complete Set` и окончание rest-таймера — тактильный отклик + световой блик (см. [services-and-repository.md · HapticsService](services-and-repository.md#35-hapticsservice--тактильный-фидбек)).
11. **Дельта = семантика.** `↑` + lime = рост (хорошо). Стрелку/знак показывать всегда рядом с метрикой.
12. **Плейсхолдеры — в лабораторном стиле.** Пока нет ассетов: полосатый градиент + mono-тег `[asset · file]`; маскот — абстрактная фигура. Заменяется на Lottie в Фазе 9.
13. **SF Symbols 6** для системной иконографики и анимации таб-бара; кастомные глифы — тонкий stroke, `currentColor`.

---

## 5. Definition of Done для компонента

- Файл в `FitnesApp/DesignSystem/Components/` — один компонент = один файл.
- API через инициализатор + `@ViewBuilder` content там, где уместно.
- Только токены `Color.App / Font.App / Spacing / Radii` — без хардкода значений (значение из макета → новый токен).
- `#Preview` со всеми состояниями (default / active / pressed / disabled / focus, danger где есть).
- Включён в `ComponentCatalog` (storybook) под `#if DEBUG`.
- Swift 6 strict concurrency: `@MainActor`, без warnings.
- Соответствует этому файлу и [userflow.md](userflow.md); при конфликте — обновляется документация, затем код.
