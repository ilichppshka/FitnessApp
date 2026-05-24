---
name: academic-format-advisor
description: "Use this skill whenever the user asks how to format an academic document in Russian or for Russian-speaking education contexts: диплом, ВКР, курсовая, реферат, отчет, отчет по практике, учебный отчет, пояснительная записка, список литературы, содержание, приложения, заголовки, таблицы, рисунки, формулы, листинги, page numbering, margins, Times New Roman, ГОСТ-like formatting, or checking whether a document follows academic formatting rules. This skill advises, checks, writes rules, checklists, and technical instructions for the docx skill. It must not directly edit .docx files; if the user wants file changes, use this skill to formulate precise requirements and then pass implementation to the docx skill."
---

# Academic Format Advisor

Use this skill as a formatting consultant for Russian academic documents: дипломы, ВКР, курсовые, рефераты, отчеты, отчеты по практике and similar учебные документы.

The rules below are extracted from an example DOCX and describe observed formatting patterns. They are not an official ГОСТ text. Treat these rules as the primary source. An explicit user preference for the current document is applied on top of them. A university методичка, кафедральный шаблон, assignment, or teacher requirements have the lowest priority and apply only where the rules and the user preference are silent. If any source conflicts with these rules, point out the conflict and ask which source should govern.

## Core Boundary

Do not directly edit `.docx` files under this skill.

When the user asks to change a `.docx`:

1. Analyze the formatting request using these rules.
2. Produce a concise technical specification for the `docx` skill.
3. State that the actual file manipulation should be performed by the `docx` skill.

Recommended handoff format:

```text
ТЗ для docx-скилла:
- Файл: <path or filename>
- Цель: привести документ к академическому оформлению по правилам academic-format-advisor.
- Страницы: A4, книжная ориентация; поля: левое 3 см, правое 1 см, верхнее 2 см, нижнее 2 см.
- Основной текст: Times New Roman 14 pt, черный, выравнивание по ширине, интервал 1,5, первая строка 1,25 см, интервалы до/после 0 pt.
- Нумерация: первая страница без видимого номера; со второй страницы номер в верхнем колонтитуле по центру, Times New Roman 14 pt.
- Содержание: автоматическое, уровни 1-2, точки-лидеры, номера страниц справа.
- Заголовки: без точки в конце; первый уровень с новой страницы; keep with next.
- Таблицы/рисунки/формулы/приложения: оформить по правилам ниже.
- После правок: проверить чек-лист соответствия и сообщить о спорных местах.
```

## How To Answer

When the user asks about a specific element:

1. Give the rule briefly.
2. Add a correct example if useful.
3. Mention that these skill rules take precedence and that university guidelines apply only where these rules are silent, if relevant.
4. If the user wants `.docx` edits, give a `docx` technical specification instead of editing the file yourself.

Example:

```text
Подпись таблицы ставится над таблицей: `Таблица 1 – Название таблицы`. Выравнивание по левому краю, Times New Roman 14 pt, интервал 1,5, перед подписью около 24 pt, после 0 pt. Точку в конце подписи не ставь. Эти правила имеют приоритет; методичка вуза применяется только там, где правила и предпочтения пользователя ничего не говорят.
```

## Source Priority

Use this priority order:

1. The rules in this skill.
2. Explicit user preference for this document.
3. User-provided university методичка, кафедральный шаблон, assignment, or teacher instruction.

A university методичка applies only where the skill rules and the user preference do not cover the case. If exact official ГОСТ or methodical compliance is requested, warn that this skill keeps its own rules on top, so strict official compliance is not guaranteed — title page, bibliography, appendices, and illustration rules must still be checked against the current university methodical requirements or ГОСТ source.

## Page Setup

| Parameter | Rule |
|---|---|
| Page format | A4 |
| Orientation | Portrait |
| Top margin | 2 cm |
| Bottom margin | 2 cm |
| Left margin | 3 cm |
| Right margin | 1 cm |
| Header distance | 1.25 cm |
| Footer distance | 1.25 cm |
| Gutter | 0 cm |
| Columns | One column |

## Page Numbers And Headers

- Page number is in the top header, centered.
- Use the automatic Word `PAGE` field.
- The title page counts as page 1 but does not show a number.
- Page numbering is visible from page 2; in the reference, the contents page appears as page 2.
- The footer is not used.
- Page number style follows the document: Times New Roman, 14 pt, black, not bold.

## Body Text

| Parameter | Rule |
|---|---|
| Font | Times New Roman |
| Size | 14 pt |
| Color | Black |
| Alignment | Justified |
| Line spacing | 1.5 |
| Spacing before | 0 pt |
| Spacing after | 0 pt |
| First-line indent | 1.25 cm |

Recommendations:

- Do not imitate paragraph indent with spaces or tabs.
- Do not add empty paragraphs between normal paragraphs.
- Avoid arbitrary fonts, colors, underlining, or decorative emphasis in body text.
- Avoid leaving a heading alone at the bottom of a page.
- Start large first-level sections on a new page.

## Document Structure

Use this broad structure when no stricter university template is provided:

1. Титульный лист.
2. Содержание.
3. Введение.
4. Main numbered sections.
5. Заключение.
6. Список литературы.
7. Приложения.

Page break rules:

- Put a page break after the title page.
- Put a page break after the contents.
- Start `Введение` on a new page.
- Start every first-level major section on a new page.
- Start `Заключение` on a new page.
- Start `Список литературы` on a new page.
- Start every appendix on a new page.

## Title Page

Do not generate or invent a title page. Reserve page 1 as an empty placeholder page that the user will replace with their own титульный лист.

Rules:

- Page 1 contains a single centered paragraph with the text `ВСТАВЬТЕ ТИТУЛЬНИК` in uppercase.
- The rest of page 1 is left empty — no other content.
- The title page still counts as page 1, and its page number is hidden.
- A page break follows page 1, so `Содержание` starts on page 2.
- When the user provides their own титульный лист (university guideline, department template, or approved example), the placeholder page is replaced by it.

## Contents

| Parameter | Rule |
|---|---|
| Heading | `Содержание` |
| Heading alignment | Centered |
| Heading first-line indent | 0 cm |
| Heading spacing after | 24 pt |
| Font | Times New Roman 14 pt |
| Line spacing | 1.5 |
| Type | Automatic Word table of contents |
| Levels included | 1-2 |
| Tab leader | Dots |
| Page number | Right aligned |

Rules:

- Include heading levels 1 and 2.
- Do not include levels 3 and 4 unless the user asks for a detailed contents.
- Use dotted leaders between the heading text and page number.
- Align page numbers to the right.
- Update the contents after structure changes.
- **TOC entry paragraphs** must have `firstLine = 0` AND `indent.left = 0` for every level — all entries are flush to the left margin, with no left indent. Levels are distinguished only by the heading numbering text (`1`, `1.1`), not by indentation. Override the built-in `TOC1` / `TOC2` paragraph styles in `styles.paragraphStyles` and zero their `left` indent, otherwise they inherit the 1.25 cm first-line indent from `Heading 1` / `Heading 2` and shift right.

## Headings

General rules:

- Times New Roman, 14 pt, black.
- No period at the end.
- Keep heading numbering visually consistent.
- Put one space between number and heading title.
- Use `keep with next` / `не отрывать от следующего`.

First-level headings:

- Use for large sections and special parts.
- Examples: `Введение`, `1 Общая часть`, `2 Специальная часть`, `Заключение`, `Список литературы`, `Приложение А`.
- Start each first-level heading on a new page.
- Center `Введение`, `Заключение`, `Список литературы`, and appendix headings.
- Numbered chapters may be left aligned as in the reference.
- Prefer chapter numbers without a trailing period in body text: `1 Общая часть`, not `1. Общая часть`.

Second-level headings:

- Use numbering like `1.1`, `1.2`, `2.1`.
- Do not put a period after the last digit.
- Do not end the heading with a period.
- Do not necessarily start on a new page.
- Include these headings in the contents.

Third-level headings:

- Use numbering like `1.1.1`, `2.3.6`, `3.1.4`.
- Do not put a period after the last digit.
- Do not start on a new page unless the text logic requires it.
- Do not include these in the contents by default.

Fourth-level headings:

- Use numbering like `2.4.3.1`.
- Use only when genuinely needed.
- Do not include these in the contents unless requested.

Heading indents and spacing:

- First-line indent:
  - Centered headings (`Введение`, `Заключение`, `Список литературы`, `Приложение …`) — 0 cm, no left indent.
  - Numbered headings of every level (`1`, `1.1`, `1.1.1`, `2.4.3.1`, …) — 1.25 cm, same as body text.
- Spacing before / after:
  - Level-1 headings and all centered headings — 24 pt *after*; no spacing *before* (they typically start on a new page).
  - Exception for appendix headings: `Приложение А` / `Приложение Б` / … has 0 pt after, because a status line `(обязательное)` / `(информационное)` follows directly on the next line with 0 pt between them; the 24 pt are applied *after the status line*, not after the appendix heading itself.
  - Level-2 heading by default — 24 pt *after*.
  - Level-2 heading sitting between body paragraphs (not directly after a level-1 heading) is framed: 24 pt before and 24 pt after.
  - Level 3 and deeper — 0 pt before and 0 pt after; the heading sits flush against the following text.
- Collapse rule for L1 → L2: when a level-2 heading directly follows a level-1 heading (no chapter intro between them), the gap between them collapses to 0 pt; only the 24 pt after the level-2 heading remains.
- Implementation:
  - `Heading 1`: `before = 0`, `after = 480` (24 pt = 480 twips); first-line indent set per paragraph — `0` for centered, `709` (1.25 cm) for numbered.
  - `Heading 2`: `before = 480`, `after = 480`, `firstLine = 709`.
  - `Heading 3` and deeper: `before = 0`, `after = 0`, `firstLine = 709`.
  - **Implementing the L1 → L2 collapse (important).** Word/LibreOffice compute the gap between adjacent paragraphs as `max(prev.spacing.after, next.spacing.before)`. To collapse the gap to 0 pt, **both sides must be zeroed** on the specific paragraphs: `L1.spacing.after = 0` AND `L2.spacing.before = 0`. Zeroing only one side leaves the other at 24 pt, which still shows as a 24 pt strip. Apply only to the L1 that is immediately followed by an L2 (no intermediate body paragraph).

## Lists

Bulleted lists:

- Use real Word lists, not manually typed symbols.
- The marker for a level-1 bulleted list is a hyphen `-` (U+002D), not `•`, `–`, or `—`.
- Times New Roman 14 pt, line spacing 1.5.
- Do not add blank lines between items.
- If items continue an introductory phrase, start with lowercase letters.
- Use `;` at the end of intermediate items and `.` at the end of the final item.

List item indents:

- First line of an item has a 1.25 cm indent — the bullet sits there.
- Subsequent (wrapped) lines of the same item have no indent (0 cm), flush to the left margin.
- For nested levels, multiply the first-line indent by the level number:
  - level 1 — 1.25 cm;
  - level 2 — 2.5 cm (1.25 × 2);
  - level 3 — 3.75 cm (1.25 × 3) and so on.
- The wrap rule still applies on every level: only the first line gets the per-level indent; continuation lines stay at 0 cm.
- Implement this via a real Word list definition (`numbering.xml`), not paragraphs with a manually typed marker. For each list level set `w:ind w:left="0"` plus `w:firstLine` in DXA/twips (709 for level 1, 1418 for level 2, 2126 for level 3; conversion: cm × 567 ≈ DXA).
- Do not use `w:hanging` — it produces the opposite layout (marker at the margin, wrapped lines aligned with the text).

Nested lists:

- Outer level: bulleted list.
- Inner level: Arabic numbers with closing parenthesis: `1)`, `2)`, `3)`.
- Keep punctuation consistent.

Numbered lists:

- Bibliography uses `1.`, `2.`, `3.`.
- Nested in-text enumerations use `1)`, `2)`, `3)`.
- Headings use hierarchical numbering without a final period: `1`, `1.1`, `1.1.1`.

## Tables

Table caption goes above the table.

Format:

```text
Таблица N – Название таблицы
```

Caption rules:

- Left aligned.
- Times New Roman 14 pt.
- Line spacing 1.5.
- Spacing before about 24 pt; spacing after 0 pt.
- Use a dash between number and title.
- Do not put a period at the end.
- If units are needed, they can be placed at the right of the same line using a tab.

Table body:

- Use Table Grid / table grid style.
- Use single borders for all outer and inner borders, about 0.5 pt.
- Usually fit table to the text area, about 17 cm.
- Use Times New Roman 14 pt in the table.
- Use single (1.0) line spacing inside tables. 1.5 is not used in tables.
- Use 0 cm paragraph indent in cells.
- Center column headers and numbers; text may be left aligned.
- Do not make the table wider than the text area.
- Avoid decorative fill unless required by the methodical guidelines.
- If the table continues on the next page, put `Окончание таблицы N` above the continuation and repeat the column structure.
- **Spacing after the table.** OOXML tables have no `after` property of their own. The 12 pt gap between the table and the following text is implemented as `spacing.before = 12 pt` (240 DXA) on the first paragraph that follows the table. Without that override the next paragraph clings to the table's bottom border.

## Figures And Images

Figure placement:

- Center figures on the page.
- Large schemes and diagrams may occupy nearly the full text width, up to about 17 cm.
- Do not let figures exceed page margins.
- Move very large figures to an appendix when appropriate.
- **Spacing around the figure** is implemented via paragraph spacing, never via blank lines:
  - the paragraph that holds the `ImageRun` itself — `spacing.before = 24 pt` (480 DXA), `spacing.after = 0`;
  - the caption paragraph — `spacing.before = 0`, `spacing.after = 24 pt`.
  - Net pattern: 24 pt — figure — 0 pt — caption — 24 pt — next text.

Figure caption goes below the figure.

Format:

```text
Рисунок N – Название рисунка
```

Rules:

- Center aligned.
- Times New Roman 14 pt.
- Line spacing 1.5.
- Spacing after about 24 pt.
- Use a dash between number and title.
- Do not put a period at the end.
- In appendices, number by appendix letter: `Рисунок А.1`, `Рисунок Б.1`.

## Formulas

Formulas are typeset as native **OMML** (Office Math Markup Language) — Word's built-in equation engine (Insert → Equation). In docx-js, use `Math`, `MathRun`, `MathFraction`, `MathSubScript`, `MathSuperScript`, `MathSum`, `MathIntegral`, `MathRadical`, `MathFunction`, etc.

Rules:

- The formula is rendered as an OMML equation, **not** as slanted text (`italics: true`) and not as an image. This yields proper math typesetting and an equation that remains editable in Word.
- The formula sits centered on a single line; the formula number is right-aligned on the same line in parentheses.
- Section-based numbering: `(3.1)`, `(3.2)`, `(3.3)`.
- Implementation in docx — **one paragraph with two tab stops** spanning the text width:
  - `alignment = LEFT`, `indent.firstLine = 0`;
  - `tabStops`:
    - `{ type: CENTER, position: contentWidth / 2 }` — centers the formula at mid-line;
    - `{ type: RIGHT, position: contentWidth }` — pins the number to the right text edge;
  - paragraph children: `TextRun("\t")` → `Math(…)` → `TextRun("\t(3.1)")`.
- The legacy borderless-table layout is **not used**. It was a workaround for environments where OMML was unavailable.
- After a formula, explanations start with `где`.

## Bibliography

Heading:

- Center the heading.
- First-line indent 0 cm.
- Times New Roman 14 pt.
- (Page break before this heading is covered by the document-wide page break rules.)

Entries:

- Use a numbered list: `1.`, `2.`, `3.`.
- Times New Roman 14 pt.
- Line spacing 1.5.
- First-line indent 1.25 cm; left indent 0 cm (wrapped lines flush to the left margin).
- Do not put blank lines between entries.
- For electronic sources, include a link and access date if required by the university guidelines.
- Consistency is more important than mixing different bibliography patterns.

## Appendices

Appendix heading format:

```text
Приложение А
(обязательное)
```

or:

```text
Приложение Г
(информационное)
```

Rules:

- Center `Приложение А`, `Приложение Б`, etc.
- Use 0 cm first-line indent for the appendix heading.
- The status line is centered.
- Use increased spacing after the status line, about 24 pt.
- Number objects inside appendices with the appendix letter: `Рисунок А.1`, `Листинг Г.1`.
- (Page break before each appendix is covered by the document-wide page break rules.)

**Appendix body structure.** Immediately after the status line comes the appendix's first object — no intermediate descriptive paragraph. The first object depends on appendix purpose:

- code appendices — first object is the listing caption `Листинг X.N – Title` followed by the code itself;
- illustration appendices (UI screens, schemes, drawings) — first object is the figure with the caption `Рисунок X.N – Title` below it; further figures or listings of the same appendix letter follow.

**Cross-references** to appendix objects (`в приложении А`, `в листинге Г.1`) live in the body text of the corresponding chapter, where the reader has a reason to look at the appendix. They are not duplicated inside the appendix itself.

## Listings And Code

Listings usually belong in appendices.

Listing caption format:

```text
Листинг Г.1 – пример кода функции
```

Rules:

- Place the listing caption before the code.
- In appendices, use numbering with the appendix letter: `Г.1`, `Г.2`.
- Use a dash between number and title.
- Do not put a period at the end.

Code formatting:

| Parameter | Rule |
|---|---|
| Font | Courier New |
| Size | 10 pt |
| Line spacing | 1.0 |
| Alignment | Left |
| Paragraph indent | 0 cm |
| Color | Black |

Recommendations:

- Move large code blocks to appendices.
- Preserve code indentation.
- Avoid screenshots of code when text listings are appropriate.

## References And Cross-References

- On first mention, refer to objects explicitly: `на рисунке 1`, `в таблице 1`, `в приложении А`, `в листинге Г.1`.
- Use lowercase object names in running text when they do not start a sentence: `рисунок`, `таблица`, `приложение`, `листинг`.
- Ensure object numbers in text match captions.
- For future DOCX editing, prefer Word fields / cross-references, but this advising skill should at least check logical consistency.

## Units And Numbers

- In tables, units may be placed in the caption line at the right: `в рублях`, `в часах`.
- Use comma as the decimal separator in Russian text: `11428,57`.
- Do not mix monetary unit formats inside one table.
- Follow the methodical guidelines for spacing before `%` if specified.

## Review Checklist

Use this checklist when asked to check or summarize formatting compliance:

- [ ] A4, portrait orientation.
- [ ] Margins: left 3 cm, right 1 cm, top 2 cm, bottom 2 cm.
- [ ] Body text Times New Roman 14 pt.
- [ ] Body text justified.
- [ ] Body line spacing 1.5.
- [ ] First-line paragraph indent 1.25 cm.
- [ ] No blank lines used instead of paragraph spacing.
- [ ] First page has no visible page number.
- [ ] Page numbers start visibly from page 2 in the top header, centered.
- [ ] Contents is automatic and includes levels 1-2.
- [ ] Contents uses dotted leaders and right-aligned page numbers.
- [ ] TOC entries have `firstLine = 0` and `left = 0` for all levels (no left indent) via overridden `TOC1` / `TOC2` paragraph styles.
- [ ] `Введение` starts on a new page.
- [ ] First-level sections start on new pages.
- [ ] `Заключение` starts on a new page.
- [ ] `Список литературы` starts on a new page.
- [ ] Each appendix starts on a new page.
- [ ] Headings do not end with periods.
- [ ] Heading numbering is consistent.
- [ ] Centered headings have 0 cm first-line indent; numbered headings have 1.25 cm.
- [ ] Level-1 and centered headings have 24 pt after; an L2 heading between body paragraphs is framed with 24 pt before and 24 pt after.
- [ ] Level 3 and deeper headings have 0 pt before and 0 pt after.
- [ ] When an L2 heading directly follows an L1 heading, the gap between them is 0 pt; only 24 pt after the L2 remains (both sides zeroed: `L1.after = 0` AND `L2.before = 0`).
- [ ] Tables have captions above them.
- [ ] Table cells use single (1.0) line spacing, not 1.5.
- [ ] First paragraph after a table has `spacing.before = 12 pt` (240 DXA).
- [ ] Figures have captions below them; figure paragraph has `before = 24 pt`, caption has `after = 24 pt`.
- [ ] Formulas are real OMML equations (`Math`/`MathRun`), not slanted text; the number `(N.M)` sits on the same line at the right via a `RIGHT` tab stop.
- [ ] Appendices: status line is immediately followed by the first object (listing caption or figure with caption); no intermediate descriptive paragraph; cross-references to appendix objects sit in the main body of the corresponding chapter.
- [ ] Bibliography is a numbered list.
- [ ] Appendices are labeled `Приложение А`, `Приложение Б` and include status where needed.
- [ ] Figures, tables, formulas, and listings have consistent numbering.
- [ ] Nested lists are formatted consistently.
- [ ] List items have a 1.25 cm first-line indent at level 1 (×N at level N) and wrapped lines flush to the left margin (0 cm), implemented via a real Word list.
- [ ] Code listings are in appendices and use Courier New 10 pt.

## Known Limits

- The title page rules cannot be derived from the source example because it only had a placeholder.
- The source example may contain small inconsistencies, such as chapter number style differences between contents and body text. Prefer consistency in new documents.
- These rules describe the extracted formatting pattern, not a complete official ГОСТ standard.
- For official compliance, cross-check the title page, bibliography, appendices, and illustration rules with current university requirements.
