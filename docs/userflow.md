# KINETIC — User Flow (по дизайну `design-claude-code`)

Документ описывает полный пользовательский флоу приложения **KINETIC** на основе финальных макетов из [docs/app-design/design-claude-code/](app-design/design-claude-code/). Является точкой опоры для реализации навигации (`TabView`, `NavigationStack`, sheets, fullscreen covers) и роутинга.

> Источники: `dashboard.jsx`, `library.jsx`, `builder.jsx`, `active.jsx`, `progress.jsx`, `settings.jsx`, `KINETIC — Onboarding.html`, `KINETIC — Profile Setup.html`, `KINETIC — Exercise Detail.html`, `KINETIC — Fitness App.html`.

---

## 0. Design System (Kinetic Laboratory)

| Параметр | Значение |
| --- | --- |
| Тема | **Dark only** |
| Surface | `#0e0f0c` · low `#131410` · high `#1f201c` · highest `#2a2b26` |
| Primary (акцент) | **Lime** `#d3f670`, on-primary `#131a00` |
| Text | on-surface `#f5f4ee` · muted `#8a8a82` |
| Шрифты | **Space Grotesk** (display/цифры) · **SF Pro** (UI) · **SF Mono** (тех-метки). Сторонних шрифтов нет — только Grotesk + системный SF |
| Визуальные коды | «лабораторный» стиль: точечные сетки, scan-lines, glow на акценте, mono-теги вида `[mascot · bench_press.lottie]`, пульсирующие точки статуса |
| Навигация | Плавающий **floating pill** таб-бар (blur + saturate), радиус 999, у нижнего края |
| Углы карточек | 16–32, крупные tap-зоны, цифры — tabular-nums |

Маскот — анимированный персонаж (Lottie), демонстрирует технику упражнения; на Active Workout и в Exercise Detail занимает верхний визуальный блок.

---

## 1. Навигация и структура

### Таб-бар — 4 основных таба

Нижний плавающий таб-бар содержит **4 основных раздела**. Остальные экраны (Workout Builder, Active Workout, Exercise Detail) — полноразмерные, открываются поверх / из этих 4 табов.

| # | Таб | Экран | Файл макета |
| --- | --- | --- | --- |
| 1 | **Home** | Dashboard | [dashboard.jsx](app-design/design-claude-code/dashboard.jsx) |
| 2 | **Library** | Exercise Library | [library.jsx](app-design/design-claude-code/library.jsx) |
| 3 | **Progress** | Progress & Analytics | [progress.jsx](app-design/design-claude-code/progress.jsx) |
| 4 | **Profile** | Settings & Profile | [settings.jsx](app-design/design-claude-code/settings.jsx) |

### Полноразмерные / презентуемые экраны

| Экран | Тип презентации | Откуда открывается | Файл макета |
| --- | --- | --- | --- |
| **Workout Builder** | Полный экран (push / fullscreen) | Home → Create / Edit plan | [builder.jsx](app-design/design-claude-code/builder.jsx) |
| **Active Workout** | Fullscreen cover (модал) | Home → Start Workout / Quick Start / тап по плану; авто-восстановление | [active.jsx](app-design/design-claude-code/active.jsx) |
| **Exercise Detail** | Bottom sheet | Library → тап по упражнению (а также из Builder/Active при добавлении) | [Exercise Detail](app-design/design-claude-code/KINETIC%20-%20Exercise%20Detail.html) |
| **Session Detail** | Push (read-only) | Progress → тап по сессии | *(нет отдельного макета — описан ниже)* |
| **Onboarding** | Fullscreen, первый запуск | Cold start (флаг не установлен) | [Onboarding](app-design/design-claude-code/KINETIC%20-%20Onboarding.html) |
| **Profile Setup** | Fullscreen, после онбординга | После Onboarding | [Profile Setup](app-design/design-claude-code/KINETIC%20-%20Profile%20Setup.html) |

> **Примечание о таб-баре.** В макетах плавающий бар отрисован с 5 слотами, а центральный слот непоследователен (`Train` на Dashboard/Library, `Progress` на Progress/Settings). Принятое решение: **4 таба** (Home · Library · Progress · Profile); запуск тренировки (`Train`) — это не таб, а действие на Home (`Start Workout` / `Quick Start`), открывающее Active Workout как полноэкранный модал. Workout Builder также не таб, а полноразмерный экран из Home.

### Карта переходов

```
[Onboarding ×3] → [Profile Setup] → [TabView · 4 таба]
                                       │
   ┌───────────────────────────────────┴───────────────────────────────────┐
   │                                                                         │
 (1) Home / Dashboard        (2) Library          (3) Progress       (4) Profile / Settings
   │                            │                    │                       │
   ├─ Start Workout ───┐        └─ Exercise Detail   └─ Session Detail        ├─ Mascot Picker
   ├─ Quick Start ─────┤            (sheet)              (read-only push)     ├─ Edit Profile
   ├─ Тап по плану ────┴──► [Active Workout]                                  ├─ Export CSV
   └─ Create / Edit plan ──► [Workout Builder] ──► (Add Exercise → Library/Detail)
                                                                              └─ Sign out / Clear data

[Active Workout] — fullscreen модал поверх TabView; при закрытии приложения сохраняется (finishedAt == nil)
```

### Восстановление активной сессии

При cold start (после пройденного онбординга) проверяется `WorkoutSession` с `finishedAt == nil`:

- **Есть незавершённая сессия** → сразу открыть **Active Workout** поверх Home.
- **Нет** → обычный TabView с активным табом Home.

---

## 2. Первый запуск

### 2.1. Onboarding — 3 шага

Полноэкранные слайды. Хедер: wordmark `KINETIC` слева, индикатор страниц (3 точки, активная — вытянутая lime-пилюля) по центру, `Skip` справа.

| Шаг | Eyebrow | Заголовок | Подзаголовок | CTA | Визуал |
| --- | --- | --- | --- | --- | --- |
| **01 · Welcome** | `WELCOME TO KINETIC` | **Train like a laboratory.** | «A high-performance training studio in your pocket. Track every rep, every set — and let the data move you forward.» | `Get Started →` | Концентрические пульс-кольца + центральный logo-знак K, mono-метки `SYS · ACTIVE`, `READY`, `v1.0` |
| **02 · Log** | `01 · LOG` | **Every rep, captured.** | «One-tap logging. Auto rest timers. Personal-record alerts. Stay locked in — your data takes care of itself.» | `Continue →` | Превью карточки Active Workout (Exercise 2 of 5, Barbell Bench Press, 75 kg × 8, Complete Set), плавающие чипы `SET 3 / 4`, `+2.5kg vs last` |
| **03 · Analyze** | `02 · ANALYZE` | **Watch yourself level up.** | «Tonnage, streaks, personal records — see exactly how every session moves you forward.» | `Start Training →` | Карточка Total Volume 72,840 kg (+18%), area-chart за 12 недель, бейдж `+6 NEW PRs`, мини-стат Sessions / Streak / Time |

**Действия:** `Get Started` / `Continue` / `Start Training` — вперёд по шагам; `Skip` — пропустить к Profile Setup.

> ✅ **Решено.** `Skip` оставляем — онбординг можно пропустить.

После шага 3 (или `Skip`) → **Profile Setup**.

### 2.2. Profile Setup

Полноэкранный экран с прокруткой и закреплённой нижней кнопкой. Хедер: wordmark `KINETIC` по центру.

**Визуал:** круговой аватар с инициалом имени + «пип» выбранного маскота, пунктирное кольцо, тик-метки по кругу.

**Заголовок:** eyebrow `FINAL STEP`, тайтл **«Set up your profile.»**, сабтайтл «Just a couple of details so we can tune KINETIC to you.»

**Форма:**

| Поле | UI | Модель |
| --- | --- | --- |
| `YOUR NAME` | Текстовое поле с активным каретом | `UserProfile.name` |
| `BODY WEIGHT` | Число + переключатель единиц `kg / lb` + степпер `− / +` | `UserProfile.bodyWeight` (+ единица веса) |
| `PICK YOUR MASCOT` (хинт `CHANGE LATER`) | Сетка 3×2 из 6 маскотов | `UserProfile.selectedMascotId` |

**Маскоты:** `Athlete` (по умолчанию), `Runner`, `Yogi`, `Climber`, `Cyclist`, `Boxer`. Выбранный — lime-обводка + чек-бейдж.

**CTA:** `Enter the Lab →` → создаёт `UserProfile`, ставит флаг «онбординг пройден», открывает TabView (Home).

> ✅ **Решено.**
> - **Права:** на Profile Setup показываем только системный запрос на отправку уведомлений (push). Тумблеры звука / хаптики / алертов — в **Settings**.
> - **Единица веса:** добавлено поле `UserProfile.weightUnit` (`kg / lb`), переключается в Settings.
> - **Маскоты:** пока **2** — «утка» (`duck`) и «бакляха» (`baklazha`); ассеты сгенерируются позже, набор `selectedMascotId` расширяемый.

---

## 3. Таб 1 — Home / Dashboard

Главный хаб. Файл: [dashboard.jsx](app-design/design-claude-code/dashboard.jsx).

**Сверху вниз:**

1. **Top bar** — eyebrow `THURSDAY · APR 16`, приветствие **«Hey, Alex»**; справа аватар с инициалом и точкой-нотификацией.
2. **Week strip** — горизонтальная полоса 7 дней (M–S). Состояния дня: `done` (с lime-точкой-маркером), `today` (lime-заливка + glow), `planned`, `rest` (приглушённый).
3. **NEXT SESSION** → **Hero card**:
   - Изображение-обложка (напр. `deadlift_hero.jpg`), пилюля `TODAY · WEEK 3`, eyebrow `UPPER / PULL`, тайтл **«Back Day»**.
   - Статы: `6 exercises` · `45 min` · `22 sets`.
   - Чипы целевых мышц: `Lats`, `Rhomboids`, `Rear Delts`, `Biceps`.
   - CTA **`Start Workout →`** → **Active Workout** по плану сегодняшнего дня.
4. **THIS WEEK** (диапазон `Apr 13 – Apr 19`) — quick-stats блок:
   - Кольцо прогресса `3/5 sessions`.
   - `TOTAL VOLUME 18,420 kg`, дельта `+12% vs last week`.
5. **Secondary row** (2 карточки):
   - **Quick Start** — `Empty workout` → **Active Workout** без плана (быстрый старт).
   - **Latest PR** — `142.5 kg · Deadlift · 2 days ago`.

**Переходы из Home:**

| Действие | Назначение |
| --- | --- |
| `Start Workout` (hero) | Active Workout (сессия по сегодняшнему `WorkoutPlan`) |
| `Quick Start` | Active Workout (сессия без плана, `plan == nil`) |
| Тап по дню недели / шаблону | Active Workout по выбранному плану |
| Create / Edit plan *(вход в конструктор)* | Workout Builder |

> Примечание: на новом Dashboard нет явной кнопки «Создать тренировку» — вход в **Workout Builder** идёт из Home (предлагается разместить рядом с week strip / hero либо как пункт списка планов). Уточнить точку входа при реализации.

---

## 4. Таб 2 — Library / Exercise Library

Каталог упражнений. Файл: [library.jsx](app-design/design-claude-code/library.jsx).

**Структура:**

1. **Top bar** — кнопка назад, кнопка фильтра; eyebrow `LIBRARY`, тайтл **«Exercises 258»**.
2. **Search** — `Search 258 exercises…`, бейдж `⌘K`.
3. **Filter chips** (горизонтальный скролл) по `MuscleGroup`: `All (258)`, `Chest`, `Back`, `Legs`, `Shoulders`, `Arms`, `Core`. Активный чип — lime.
4. **Exercise of the Day** (featured) — крупная карточка: `Barbell Row`, `Lats · Rhomboids · Rear delts`, кнопка-стрелка → Exercise Detail.
5. **RECENT** (2) — недавние упражнения с PR.
6. **ALL · BACK** (34, действие `Sort`) — список карточек упражнений.

**Карточка упражнения (`ExerciseRow`):**
- Превью-thumb с иконкой play (демо маскота), опц. маркер `featured`.
- Имя + опц. тег (`Cable`/`Barbell`).
- Мышцы (`Lats · Biceps · …`).
- Сложность: 3-полосный индикатор + лейбл `Beginner` / `Intermediate` / `Advanced`.
- Личный рекорд: `PR 142.5kg`.
- Кнопка **`+`** — добавить упражнение (в текущий план / быстрый старт).

**Переход:** тап по карточке → **Exercise Detail** (bottom sheet).

---

## 5. Exercise Detail (bottom sheet поверх Library)

Файл: [Exercise Detail](app-design/design-claude-code/KINETIC%20-%20Exercise%20Detail.html). Открывается как sheet с drag-handle поверх затемнённого каталога.

**Хедер sheet:** close `×`, eyebrow `EXERCISE · BACK`, кнопка share/export.

**Тело (скролл):**

1. **Title block** — тег `BARBELL`, сложность `Intermediate` (полосы), тайтл **«Bent-Over Row»**.
2. **Mascot panel** — анимированное демо техники (`TECHNIQUE LOOP`, mono-тег `[mascot · bench_press.lottie]`), плеер: play, прогресс-бар, `0:04 / 0:12`.
3. **TARGET MUSCLES** — чипы: первичные (lime) `Lats`, `Rhomboids`, `Mid Traps`; вторичные `Rear Delts`, `Biceps`, `Forearms`.
4. **Tabs:** `Technique` (актив) · `PRs` · `History`.
5. **SETUP** — исходное положение (`descriptionStart`).
6. **EXECUTION** — нумерованные шаги (`descriptionExecution`):
   1. Brace & set the back
   2. Drive the elbows up
   3. Controlled descent
7. **COMMON MISTAKES** — список ошибок с красным `×` (`descriptionErrors`).
8. **PERSONAL RECORD** (действие `History →`) — карточка PR:
   - `82.5 kg × 8`
   - `EST. 1RM 98.5 kg` · `LAST SET 75 kg` · `ATTEMPTS 42`

**Закреплённый низ:** кнопка ⭐ (избранное) + CTA **`Add to Workout +`**.

> ✅ **Решено.** Расширяем: `isFavorite` добавлен в `Exercise`; `Est. 1RM` и `Attempts` — производные в `AnalyticsService` (из `PersonalRecord`); вкладки `Technique/PRs/History` и share — на уровне UI.

---

## 6. Workout Builder (полноразмерный, из Home)

Конструктор плана. Файл: [builder.jsx](app-design/design-claude-code/builder.jsx).

**Структура:**

1. **Top bar** — назад, пилюля `Save Draft`; eyebrow `NEW PROGRAM · DAY 1`, тайтл **«Push Day»**, статус `Auto-saved · 12s ago`.
2. **Summary** — `EXERCISES 5` · `EST. TIME 48 min` · `TOTAL SETS 18`.
3. **`EXERCISES · DRAG TO REORDER`** — список `PlanExercise` (drag-handle для сортировки по `order`):
   - Индекс-бейдж, имя, мышцы.
   - В свёрнутом виде: компактно `4 × 8` + шеврон.
   - В развёрнутом виде (1-е упражнение): таблица сетов (`SET / WEIGHT / REPS / ×`), кнопка `Add set`, блок **`Rest between sets 02:00`** (`restDuration`).
   - Пример: `Barbell Bench Press` 4×8-12 rest 02:00; `Incline Dumbbell Press` 4×10-12 rest 01:30; `Cable Chest Fly` 3×12-15 rest 01:00; `Overhead Press` 4×6-10 rest 02:00; `Tricep Pushdown` 3×12-15 rest 01:00.
4. **Add Exercise** (пунктирная кнопка) → выбор упражнения из Library / Exercise Detail.
5. **Bottom bar** — `5 EXERCISES · 18 SETS` / `~48 min total` + CTA **`Save Plan →`**.

**Сохранение** → создаётся/обновляется `WorkoutPlan` с упорядоченными `PlanExercise` → возврат на Home.

---

## 7. Active Workout (fullscreen модал)

Активная сессия. Файл: [active.jsx](app-design/design-claude-code/active.jsx). Без таб-бара — сфокусированный полноэкранный режим.

**Структура:**

1. **Top bar** — close `×`, по центру общий таймер сессии `SESSION 24:18`, кнопка `⋯`.
2. **Mascot canvas** — демо техники текущего упражнения (`LIVE · TECHNIQUE`, mono-тег ассета), тайм-теги `0:00 / 2:18 / 1.0×`.
3. **Exercise info** — `EXERCISE 2 OF 5 · CHEST`, тайтл **«Barbell Bench Press»**, точки прогресса сетов (2 из 4 выполнено), `Set 3 of 4 · Last set: 70kg × 10`.
4. **Input blocks** (крупные, под одну руку):
   - `WEIGHT 75 kg` с подсказкой `↑ +5kg` и степпером `− / +`.
   - `REPS 8` со степпером `− / +`.
5. **CTA** **`Complete Set`** (`75 × 8`) — логирование подхода + хаптик/shimmer.
6. **Bottom bar — таймер отдыха** (плавающая панель):
   - `REST · NEXT SET IN 1:23`, прогресс-бар (58%).
   - Кнопки: `−15s`, `+15s`, `Skip`.

**Логика (см. [AGENTS.md](../AGENTS.md) · Logic & Tracking):**
- `Complete Set` → создаёт `WorkoutSet` (сразу в SwiftData), запускает таймер отдыха, по истечении — локальное уведомление (`UserNotifications`).
- Авто-переход к следующему сету / упражнению; точки прогресса и `EXERCISE n OF m` обновляются.
- Общий таймер `startedAt → now`.
- При закрытии приложения сессия сохраняется (`finishedAt == nil`) и восстанавливается при следующем запуске.
- `close ×` / завершение → проставляет `finishedAt`, агрегирует `totalTonnage`.

> ✅ **Решено.** Добавляем логику прогрессии (Logic-агент): рекомендация веса следующего подхода (`↑ +5kg`) и подтяжка прошлого результата (`Last set: 70kg × 10`) на основе истории `WorkoutSet` / `PersonalRecord`.

---

## 8. Таб 3 — Progress & Analytics

История и аналитика завершённых сессий (`WorkoutSession` с `finishedAt != nil`). Файл: [progress.jsx](app-design/design-claude-code/progress.jsx).

**Структура:**

1. **Top bar** — назад, кнопка экспорта/скачивания; eyebrow `ANALYTICS`, тайтл **«Progress»**.
2. **Range tabs:** `Week` · `Month` (актив) · `3M` · `Year` · `All`.
3. **Hero metric** — `TOTAL VOLUME · 4 WEEKS` = `72,840 kg`, дельта `+18.2% vs previous 4 weeks`.
4. **Volume chart** (`SwiftUI.Charts`) — `WEEKLY TONNAGE 22,400 kg`, area-график (`Feb / Mar / Apr / This wk`), маркер последней точки, `This week ↑`.
5. **Stats grid (2×2):** `SESSIONS 14 (+2)` · `TIME 11h 24m (+1h)` · `NEW PRs 6 (+3)` · `STREAK 21 days`.
6. **RECENT SESSIONS** (действие `View all`) — список завершённых сессий:
   - `Push Day · Bench focus` — APR 28 · 52m · 6,420 kg · 22 sets · **PR**
   - `Pull Day · Back & Biceps` — APR 26 · 48m · 5,840 kg · 20 sets
   - `Leg Day · Heavy` — APR 24 · 64m · 8,250 kg · 24 sets · **PR**
   - `Push Day · Volume` — APR 22 · 45m · 5,200 kg · 22 sets

**Переход:** тап по сессии → **Session Detail** (read-only).

### Session Detail (read-only, push)

Отдельного макета нет — описание по [AGENTS.md](../AGENTS.md): упражнения сессии, подходы `вес × повторы`, итоговый `totalTonnage`, длительность (`startedAt → finishedAt`), отметки PR. Только просмотр, без редактирования.

> ✅ **Решено.** Метрики `STREAK` (серия дней), `NEW PRs` и дельты (`+2`, `+1h`, `+3`, vs предыдущий период), фильтрация по диапазону — считает `AnalyticsService`.

---

## 9. Таб 4 — Profile / Settings

Профиль и настройки. Файл: [settings.jsx](app-design/design-claude-code/settings.jsx).

**Структура:**

1. **Top bar** — назад, ссылка `Edit`; eyebrow `PROFILE`, тайтл **«Settings»**.
2. **Profile card** — аватар (инициал) с кнопкой-пип редактирования, **«Alex Morgan»**, `alex@kinetic.app · Member since Feb 2024`, статы: `WEIGHT 78 kg` · `HEIGHT 182 cm` · `LEVEL 3` (lime).
3. **Mascot preview** — `YOUR MASCOT · Athlete · Default`, «Tap to change character», бейдж `4 LEFT` → **Mascot Picker**.
4. **TRAINING:** `Default rest timer 01:30` · `Weight unit Kilograms` · `Auto-start rest timer` (тумблер, on).
5. **NOTIFICATIONS & FEEDBACK:** `Rest timer alerts` (on) · `Haptic feedback` (on) · `Weekly summary email` (off).
6. **DATA:** `Export to CSV` · `Apple Health Connected` · `Clear workout history` (danger).
7. **ACCOUNT:** `Personal information` · `Privacy & security` · `Sign out` (danger).
8. **Footer:** `KINETIC v1.0.4 · build 2026.04.30`.

**Соответствие модели `UserProfile`:** `name`, `bodyWeight`, `selectedMascotId`, `restSoundEnabled` (→ `Rest timer alerts`), `restHapticEnabled` (→ `Haptic feedback`). `Export to CSV` → `CSVExporter`.

> ✅ **Решено.** Добавлены поля `UserProfile`: `weightUnit` (`kg / lb`), `defaultRestDuration`, `autoStartRestTimer` (+ существующие `restSoundEnabled` / `restHapticEnabled`). **Авторизацию пока не делаем** — план: вход через **Telegram ID (OAuth)**, тогда добавятся `telegramUserId` / `email`. `Apple Health`, `Weekly summary email`, `height` / `level` — на потом.

---

## 10. Сводка расхождений с `AGENTS.md` (решения зафиксированы)

Все пункты решены и перенесены в [AGENTS.md](../AGENTS.md).

| # | Тема | В новом дизайне | ✅ Решение |
| --- | --- | --- | --- |
| 1 | Кол-во табов | 4 таба + плавающий бар; центр-слот спорный | 4 таба (Home · Library · Progress · Profile); `Train`/Builder — не табы, а полноэкранные экраны |
| 2 | Онбординг | Есть `Skip` | Оставляем `Skip` (можно пропустить онбординг) |
| 3 | Профиль · права | Прав нет; тумблеры в Settings | На Profile Setup — только системный запрос на отправку уведомлений; тумблеры звука/хаптики/алертов в Settings |
| 4 | Единицы веса | Переключатель `kg / lb` | Поле `UserProfile.weightUnit` (`kg / lb`), переключается в Settings |
| 5 | Маскоты | 6 в макете | Пока **2**: «утка» (`duck`) и «бакляха» (`baklazha`); ассеты сгенерируются позже, список расширяемый |
| 6 | Active Workout | suggested weight, last set, `−15s/+15s/Skip` | Добавляем логику прогрессии (рекомендация веса + прошлый результат) в Logic-агент |
| 7 | Exercise Detail | табы, Est.1RM, Attempts, избранное, share | Расширяем: `isFavorite` в `Exercise`; `Est.1RM`/`Attempts` — производные в `AnalyticsService` |
| 8 | Progress | Streak, NewPRs, дельты, range-tabs | Добавляем метрики в `AnalyticsService` (streak, новые PR, дельты периодов, диапазоны) |
| 9 | Settings · Account | email/account | Авторизацию пока **не делаем**; план — вход через **Telegram ID (OAuth)** |

---

## 11. Чек-лист навигации для реализации

- [ ] `RootView`: ветвление cold start — Onboarding → Profile Setup → TabView; либо сразу TabView; либо Active Workout (если `finishedAt == nil`).
- [ ] `TabView` с 4 табами: Home, Library, Progress, Profile (плавающий кастомный таб-бар, Dark only).
- [ ] Home → `fullScreenCover` Active Workout; push/fullscreen Workout Builder.
- [ ] Library → `.sheet` Exercise Detail (drag-handle, крупный detent).
- [ ] Progress → push Session Detail (read-only).
- [ ] Profile → Mascot Picker, Edit Profile, Export CSV, диалоги danger-действий.
- [ ] Active Workout: сохранение `WorkoutSet` сразу, таймер отдыха + `UserNotifications`, авто-переход, восстановление сессии.
