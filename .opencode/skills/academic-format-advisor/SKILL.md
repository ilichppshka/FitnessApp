---
name: academic-format-advisor
description: "Use this skill whenever the user asks how to format an academic document in Russian or for Russian-speaking education contexts: диплом, ВКР, курсовая, реферат, отчет, отчет по практике, учебный отчет, пояснительная записка, список литературы, содержание, приложения, заголовки, таблицы, рисунки, формулы, листинги, page numbering, margins, Times New Roman, ГОСТ-like formatting, or checking whether a document follows academic formatting rules. This skill advises, checks, writes rules, checklists, and technical instructions for the docx skill. It must not directly edit .docx files; if the user wants file changes, use this skill to formulate precise requirements and then pass implementation to the docx skill."
---

# Academic Format Advisor

Use this skill as a formatting consultant for Russian academic documents: дипломы, ВКР, курсовые, рефераты, отчеты, отчеты по практике and similar учебные документы.

The rules below are extracted from an example DOCX and describe observed formatting patterns. They are not an official ГОСТ text and do not replace university guidelines. If the user provides a методичка, кафедральный шаблон, assignment, or teacher requirements, treat those as higher priority. If they conflict with these rules, point out the conflict and ask which source should govern.

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
3. Mention that university guidelines override this reference if relevant.
4. If the user wants `.docx` edits, give a `docx` technical specification instead of editing the file yourself.

Example:

```text
Подпись таблицы ставится над таблицей: `Таблица 1 - Название таблицы`. Выравнивание по левому краю, Times New Roman 14 pt, интервал 1,5, перед подписью около 24 pt, после 0 pt. Точку в конце подписи не ставь. Если в методичке вуза указано иначе, следуй методичке.
```

## Source Priority

Use this priority order:

1. User-provided university методичка, кафедральный шаблон, assignment, or teacher instruction.
2. Explicit user preference for this document.
3. The rules in this skill.

If exact official compliance is requested, warn that title page, bibliography, appendices, and illustration rules must be checked against the current university methodical requirements or ГОСТ source.

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

The source example contains only a title-page placeholder, so do not invent exact title-page structure.

Advise the user to provide a university guideline, department template, or approved example. Keep only the general principles: the title page is page 1, its number is hidden, and a page break follows it.

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

## Lists

Bulleted lists:

- Use real Word lists, not manually typed symbols.
- Times New Roman 14 pt, line spacing 1.5.
- Keep visual indent consistent with the 1.25 cm paragraph indent.
- Do not add blank lines between items.
- If items continue an introductory phrase, start with lowercase letters.
- Use `;` at the end of intermediate items and `.` at the end of the final item.

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
Таблица N - Название таблицы
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
- Use single or compact line spacing inside tables if 1.5 makes the table too bulky.
- Use 0 cm paragraph indent in cells.
- Center column headers and numbers; text may be left aligned.
- Do not make the table wider than the text area.
- Avoid decorative fill unless required by the methodical guidelines.
- If the table continues on the next page, put `Окончание таблицы N` above the continuation and repeat the column structure.

## Figures And Images

Figure placement:

- Center figures on the page.
- Large schemes and diagrams may occupy nearly the full text width, up to about 17 cm.
- Do not let figures exceed page margins.
- Move very large figures to an appendix when appropriate.

Figure caption goes below the figure.

Format:

```text
Рисунок N - Название рисунка
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

In the reference, formulas and formula numbers are laid out with a borderless table: formula in a wide left cell, number in a narrow right cell.

Rules:

- Center the formula.
- Put the formula number at the right in parentheses.
- Use section-based numbering: `(3.1)`, `(3.2)`, `(3.3)`.
- Do not show borders around the layout table.
- The left part is about 15 cm and the right part about 2.26 cm.
- After a formula, explanations may start with `где`.
- Do not use formula screenshots when Word formulas can be typed.

## Bibliography

Heading:

- `Список литературы` starts on a new page.
- Center the heading.
- First-line indent 0 cm.
- Times New Roman 14 pt.

Entries:

- Use a numbered list: `1.`, `2.`, `3.`.
- Times New Roman 14 pt.
- Line spacing 1.5.
- Visual indent should match 1.25 cm.
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

- Each appendix starts on a new page.
- Center `Приложение А`, `Приложение Б`, etc.
- Use 0 cm first-line indent for the appendix heading.
- The status line is centered.
- Use increased spacing after the status line, about 24 pt.
- Number objects inside appendices with the appendix letter: `Рисунок А.1`, `Листинг Г.1`.

## Listings And Code

Listings usually belong in appendices.

Listing caption format:

```text
Листинг Г.1 - пример кода функции
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
- [ ] `Введение` starts on a new page.
- [ ] First-level sections start on new pages.
- [ ] `Заключение` starts on a new page.
- [ ] `Список литературы` starts on a new page.
- [ ] Each appendix starts on a new page.
- [ ] Headings do not end with periods.
- [ ] Heading numbering is consistent.
- [ ] Tables have captions above them.
- [ ] Figures have captions below them.
- [ ] Formulas have right-aligned numbers in parentheses.
- [ ] Bibliography is a numbered list.
- [ ] Appendices are labeled `Приложение А`, `Приложение Б` and include status where needed.
- [ ] Figures, tables, formulas, and listings have consistent numbering.
- [ ] Nested lists are formatted consistently.
- [ ] Code listings are in appendices and use Courier New 10 pt.

## Known Limits

- The title page rules cannot be derived from the source example because it only had a placeholder.
- The source example may contain small inconsistencies, such as chapter number style differences between contents and body text. Prefer consistency in new documents.
- These rules describe the extracted formatting pattern, not a complete official ГОСТ standard.
- For official compliance, cross-check the title page, bibliography, appendices, and illustration rules with current university requirements.
