```markdown
# Design System Specification: High-End Fitness & Performance
 
## 1. Overview & Creative North Star
**Creative North Star: The Kinetic Laboratory**
This design system moves away from the "recreational fitness" aesthetic into the realm of high-performance bio-hacking and futuristic athleticism. It is designed to feel like a premium heads-up display (HUD) found in elite training facilities. 
 
We break the "standard app" mold by rejecting rigid grids and boxed-in content. Instead, we utilize **Intentional Asymmetry** and **Tonal Depth**. By overlapping high-contrast typography over muted, translucent surfaces, we create an editorial feel that prioritizes data visualization and kinetic energy. The interface doesn't just display information; it vibrates with potential.
 
---
 
## 2. Color & Atmospheric Theory
The palette is rooted in deep, "obsidian-olive" tones, providing a sophisticated alternative to pure black. This creates a more natural, "night-vision" depth.
 
### Core Palette
- **Surface (Main):** `#0e0f0c` (The deep abyss of the training floor)
- **Surface Container (Low):** `#131410` (Subtle sectioning)
- **Surface Container (High):** `#1f201c` (Elevated interactive elements)
- **Primary (Neon Lime):** `#d3f670` (The pulse of the system)
- **On-Primary:** `#131a00` (Maximized legibility on neon)
 
### The "No-Line" Rule
Traditional 1px borders are strictly prohibited for structural sectioning. Boundaries must be defined through **Background Color Shifts**. To separate a "Workout Summary" from the "Main Feed," transition from `surface` to `surface-container-low`. 
 
### Signature Textures
- **The Neon Glow:** For primary CTAs, apply a `primary` glow: `drop-shadow(0px 0px 12px rgba(186, 219, 89, 0.45))`. 
- **Glassmorphism:** Floating elements (like the Navigation Pill) must use `surface-container-highest` at 60% opacity with a `20px` backdrop blur. This ensures the UI feels like a physical lens hovering over the data.
 
---
 
## 3. Typography: The Editorial Scale
We pair the technical precision of **Space Grotesk** for data and headlines with the adaptive legibility of **SF Pro (Inter variant)** for functional UI.
 
| Level | Token | Font | Size | Case | Tracking |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display** | `display-lg` | Space Grotesk | 3.5rem | Bold | -0.02em |
| **Headline** | `headline-lg` | Space Grotesk | 2rem | Medium | -0.01em |
| **Title** | `title-lg` | SF Pro (Inter) | 1.375rem | Semibold | Normal |
| **Body** | `body-md` | SF Pro (Inter) | 0.875rem | Regular | Normal |
| **Label** | `label-sm` | SF Pro (Inter) | 0.6875rem | Bold | +0.05em (Caps) |
 
**Editorial Note:** Use `display-lg` for numeric values (e.g., Heart Rate, Weight). Use `label-sm` in ALL CAPS for category headers to create an authoritative, technical look.
 
---
 
## 4. Elevation & Depth
In this system, depth is a result of **Tonal Layering**, not shadows.
 
- **The Layering Principle:** 
    - Level 0: `surface` (The base)
    - Level 1: `surface-container-low` (Secondary content blocks)
    - Level 2: `surface-container-high` (Interactive cards)
- **Ambient Shadows:** Only used for floating modals or "pills." Use a "Tinted Shadow": `shadow-color: rgba(186, 219, 89, 0.08)`, Blur: `32px`, Y: `16px`.
- **The Ghost Border:** If a border is required for accessibility (e.g., Input Fields), use `outline-variant` (`#484844`) at **15% opacity**. Never use a solid, high-contrast line.
 
---
 
## 5. Components
 
### Floating Navigation Pill (iOS Style)
A signature "floating pill" container at the bottom of the screen.
- **Background:** `surface-container-highest` @ 70% opacity.
- **Blur:** 25px Backdrop Blur.
- **Border:** 0.5px "Ghost Border" using `primary` @ 10% opacity for a subtle rim-light effect.
- **Corner Radius:** `full`.
 
### Kinetic Buttons
- **Primary:** `primary` background, `on-primary` text. No border. Apply `2.5` spacing (0.85rem) on top/bottom and `6` spacing (2rem) on sides.
- **Secondary:** Transparent background with a `ghost-border`. Text color: `primary`.
- **States:** On press, the "Neon Glow" intensity increases from 45% to 80% opacity.
 
### Performance Cards
- **Structure:** No dividers. Use `surface-container-highest` for the card body. 
- **Corner Radius:** `md` (1.5rem) for a modern, rounded feel that fits the iOS ecosystem.
- **Content:** Information should be grouped using vertical white space (`4` or `5` spacing tokens) rather than lines.
 
### Inputs & Toggles
- **Fields:** Use `surface-container-low` with a subtle `1.5` rounded corner. The label sits above the field in `label-sm` (Caps).
- **Toggles:** When "ON," the track uses `primary` with a subtle glow. When "OFF," it uses `surface-container-highest`.
 
---
 
## 6. Do’s and Don’ts
 
### Do:
- **Use High-Contrast Scaling:** Place a `display-lg` number right next to a `label-sm` text block to create visual tension and hierarchy.
- **Embrace Breathing Room:** Use the `10` (3.5rem) and `12` (4rem) spacing tokens between major sections to let the data breathe.
- **Neon Accents:** Use the `primary` color sparingly. It should represent "action" or "active state" only.
 
### Don't:
- **Don't use Dividers:** Never use a horizontal line to separate two list items. Use a `0.35rem` background color shift or `1rem` of empty space.
- **Don't use Pure White:** Use `on-surface` (`#f5f4ee`) for high emphasis text. Pure white is too harsh for this dark, technical palette.
- **Don't use Standard Shadows:** Avoid black drop shadows. They muddy the deep olive background. Always use tinted, diffused glows.