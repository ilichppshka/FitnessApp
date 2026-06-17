#if DEBUG || DESIGN_SYSTEM_APP
import SwiftUI

// swiftlint:disable:next type_body_length
struct ComponentCatalog: View {
    @State private var nameField: String = ""
    @State private var weightField: String = "80"
    @State private var repsField: String = ""
    @State private var searchField: String = ""
    @State private var toggleOn: Bool = true
    @State private var toggleOff: Bool = false
    @State private var navTab: NavTab = .dashboard
    @State private var muscleFilter: Muscle = .all

    enum NavTab: String, CaseIterable, Hashable {
        case dashboard, library, builder, progress, settings

        var systemImage: String {
            switch self {
            case .dashboard: "house.fill"
            case .library: "dumbbell.fill"
            case .builder: "list.bullet.rectangle"
            case .progress: "chart.bar.fill"
            case .settings: "gearshape.fill"
            }
        }

        var label: String {
            switch self {
            case .dashboard: "ГЛАВНАЯ"
            case .library: "БИБЛ"
            case .builder: "ПЛАНЫ"
            case .progress: "ПРОГРЕСС"
            case .settings: "НАСТР"
            }
        }
    }

    enum Muscle: String, CaseIterable, Hashable {
        case all = "All 258"
        case chest = "Chest"
        case back = "Back"
        case legs = "Legs"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                    colorsSection
                    typographySection
                    effectsSection
                    sectionLabelsSection
                    screenHeadersSection
                    buttonsSection
                    iconChipsSection
                    textButtonsSection
                    chipsSection
                    badgesSection
                    statusDotsSection
                    avatarsSection
                    progressDotsSection
                    progressRingsSection
                    togglesSection
                    steppersSection
                    cardsSection
                    inputsSection
                    searchSection
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)
                .padding(.bottom, 120)
            }

            FloatingNavPill(
                selection: $navTab,
                icon: { Image(systemName: $0.systemImage) },
                title: { $0.label }
            )
            .padding(.bottom, Spacing.lg)
        }
        .kineticTheme()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("KINETIC LABORATORY")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.primary)
            Text("Component Catalog")
                .font(Font.App.headlineLg)
        }
    }

    private var colorsSection: some View {
        section(title: "COLORS") {
            HStack(spacing: Spacing.sm) {
                colorSwatch(Color.App.surface, name: "surface")
                colorSwatch(Color.App.surfaceContainerLow, name: "low")
                colorSwatch(Color.App.surfaceContainerHigh, name: "high")
                colorSwatch(Color.App.surfaceContainerHighest, name: "highest")
            }
            HStack(spacing: Spacing.sm) {
                colorSwatch(Color.App.primary, name: "primary")
                colorSwatch(Color.App.onPrimary, name: "onPrimary")
                colorSwatch(Color.App.glow, name: "glow")
            }
            HStack(spacing: Spacing.sm) {
                colorSwatch(Color.App.onSurface, name: "onSurface")
                colorSwatch(Color.App.onSurfaceMuted, name: "muted")
                colorSwatch(Color.App.outlineVariant, name: "outline")
            }
            HStack(spacing: Spacing.sm) {
                colorSwatch(Color.App.danger, name: "danger")
                colorSwatch(Color.App.live, name: "live")
            }
        }
    }

    private var typographySection: some View {
        section(title: "TYPOGRAPHY") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("12 480 кг").kineticText(.displayLg)
                Text("Push Day").kineticText(.headlineLg)
                Text("Жим штанги").kineticText(.titleLg)
                Text("Базовое движение для груди").kineticText(.bodyMd)
                Text("тоннаж за неделю").kineticText(.labelSm).foregroundStyle(Color.App.onSurfaceMuted)
            }
            .foregroundStyle(Color.App.onSurface)
        }
    }

    private var effectsSection: some View {
        section(title: "EFFECTS") {
            // Neon Glow
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Neon Glow — rest 0.45 / press 0.80")
                    .kineticText(.labelSm)
                    .foregroundStyle(Color.App.onSurfaceMuted)
                HStack(spacing: Spacing.lg) {
                    Circle()
                        .fill(Color.App.primary)
                        .frame(width: 48, height: 48)
                        .neonGlow()
                    Circle()
                        .fill(Color.App.primary)
                        .frame(width: 48, height: 48)
                        .neonGlow(opacity: 0.80)
                    Circle()
                        .fill(Color.App.primary.opacity(0.3))
                        .frame(width: 48, height: 48)
                        .neonGlow(isActive: false)
                }
            }
            // Ghost Border
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Ghost Border — 15% default / 10% rim-light")
                    .kineticText(.labelSm)
                    .foregroundStyle(Color.App.onSurfaceMuted)
                HStack(spacing: Spacing.md) {
                    RoundedRectangle(cornerRadius: Radii.md)
                        .fill(Color.App.surfaceContainerHigh)
                        .frame(height: 44)
                        .ghostBorder(cornerRadius: Radii.md)
                    RoundedRectangle(cornerRadius: Radii.pill)
                        .fill(Color.App.surfaceContainerHighest.opacity(0.7))
                        .frame(height: 44)
                        .ghostBorder(color: Color.App.primary, opacity: 0.10, cornerRadius: Radii.pill, lineWidth: 0.5)
                }
            }
            // Tinted Shadow + Glass
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Tinted Shadow + Glass (nav pill)")
                    .kineticText(.labelSm)
                    .foregroundStyle(Color.App.onSurfaceMuted)
                Text("Glass pill")
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)
                    .glassBackground()
                    .ghostBorder(color: Color.App.primary, opacity: 0.10, cornerRadius: Radii.pill, lineWidth: 0.5)
                    .tintedShadow()
            }
        }
    }

    private var sectionLabelsSection: some View {
        section(title: "SECTION LABELS") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionLabel(text: "Next Session")
                SectionLabel(text: "This Week")
                SectionLabel(text: "Notifications & Feedback")
            }
        }
    }

    private var screenHeadersSection: some View {
        section(title: "SCREEN HEADERS") {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                ScreenHeader(label: "Library", title: "Exercises", accent: "258")
                ScreenHeader(label: "Profile", title: "Settings")
            }
        }
    }

    private var buttonsSection: some View {
        section(title: "BUTTONS") {
            VStack(spacing: Spacing.sm) {
                KineticButton(title: "Quick Start", action: {})
                KineticButton(
                    title: "Save Plan",
                    trailingSystemName: "chevron.right",
                    action: {}
                )
                KineticButton(
                    title: "Complete Set",
                    trailingSystemName: "checkmark",
                    action: {}
                )
                KineticButton(title: "Создать план", style: .secondary, action: {})
                KineticButton(title: "Disabled", isEnabled: false, action: {})
            }
        }
    }

    private var iconChipsSection: some View {
        section(title: "ICON CHIPS") {
            HStack(spacing: Spacing.sm) {
                IconChip(systemName: "chevron.left", action: {})
                IconChip(systemName: "xmark", action: {})
                IconChip(systemName: "ellipsis", action: {})
                IconChip(systemName: "arrow.down.to.line", action: {})
                IconChip(systemName: "line.3.horizontal.decrease", action: {})
            }
        }
    }

    private var textButtonsSection: some View {
        section(title: "TEXT BUTTONS") {
            HStack(spacing: Spacing.lg) {
                TextButton(title: "Edit", action: {})
                TextButton(
                    title: "This week",
                    trailingSystemName: "arrow.up",
                    action: {}
                )
                TextButton(
                    title: "Save Draft",
                    style: .pill,
                    foreground: Color.App.onSurface,
                    action: {}
                )
            }
        }
    }

    private var chipsSection: some View {
        section(title: "CHIPS") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Muscle.allCases, id: \.self) { muscle in
                        Chip(
                            title: muscle.rawValue,
                            style: muscleFilter == muscle ? .selected : .outline,
                            action: { muscleFilter = muscle }
                        )
                    }
                }
                HStack(spacing: Spacing.sm) {
                    Chip(title: "TODAY · WEEK 3", style: .subtle)
                    Chip(title: "4 LEFT", style: .subtle)
                }
                HStack(spacing: Spacing.sm) {
                    Chip(title: "+18.2%", style: .delta, leadingSystemName: "arrow.up")
                    Chip(title: "+5kg", style: .delta, leadingSystemName: "arrow.up")
                    Chip(title: "+1h", style: .delta, leadingSystemName: "arrow.up")
                }
            }
        }
    }

    private var badgesSection: some View {
        section(title: "BADGES") {
            HStack(spacing: Spacing.lg) {
                Badge(text: "1")
                Badge(text: "2", style: .outlined)
                Badge(text: "12", size: 36)
            }
        }
    }

    private var statusDotsSection: some View {
        section(title: "STATUS DOTS") {
            HStack(spacing: Spacing.lg) {
                HStack(spacing: Spacing.xs) {
                    StatusDot(pulses: true)
                    Text("LIVE").font(Font.App.labelSm)
                }
                HStack(spacing: Spacing.xs) {
                    StatusDot()
                    Text("Auto-saved · 12s ago")
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.6))
                }
            }
        }
    }

    private var avatarsSection: some View {
        section(title: "AVATARS") {
            HStack(spacing: Spacing.lg) {
                AvatarCircle(initial: "A")
                AvatarCircle(initial: "AM", size: 56)
                AvatarCircle(
                    initial: "A",
                    size: 72,
                    overlayBadge: Image(systemName: "chevron.left")
                )
            }
        }
    }

    private var progressDotsSection: some View {
        section(title: "PROGRESS DOTS") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ProgressDots(total: 4, completed: 3)
                ProgressDots(total: 5, completed: 0)
                ProgressDots(total: 5, completed: 5, size: 8)
            }
        }
    }

    private var progressRingsSection: some View {
        section(title: "PROGRESS RINGS") {
            HStack(spacing: Spacing.xl) {
                ProgressRing(progress: 0.6, size: 56) {
                    Text("3/5")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.App.onSurface)
                }
                ProgressRing(progress: 0.25)
                ProgressRing(progress: 1.0, lineWidth: 6, size: 80) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }

    private var togglesSection: some View {
        section(title: "TOGGLES") {
            HStack(spacing: Spacing.lg) {
                KineticToggle(isOn: $toggleOn)
                KineticToggle(isOn: $toggleOff)
            }
        }
    }

    private var steppersSection: some View {
        section(title: "STEPPER BUTTONS") {
            HStack(spacing: Spacing.lg) {
                StepperButton(kind: .minus, action: {})
                StepperButton(kind: .plus, action: {})
                StepperButton(kind: .plus, isEnabled: false, action: {})
            }
        }
    }

    private var cardsSection: some View {
        section(title: "CARDS") {
            VStack(spacing: Spacing.sm) {
                PerformanceCard {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("ТОННАЖ ЗА НЕДЕЛЮ")
                            .font(Font.App.labelSm)
                            .foregroundStyle(Color.App.onSurface.opacity(0.6))
                        Text("12 480 кг")
                            .font(Font.App.displayLg)
                            .foregroundStyle(Color.App.primary)
                    }
                }
                PerformanceCard(action: {}, content: {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Push Day").font(Font.App.titleLg)
                            Text("4 упражнения · 45 мин")
                                .font(Font.App.bodyMd)
                                .foregroundStyle(Color.App.onSurface.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.App.onSurface.opacity(0.4))
                    }
                })
            }
        }
    }

    private var inputsSection: some View {
        section(title: "INPUTS") {
            VStack(spacing: Spacing.lg) {
                GhostInputField(placeholder: "Имя", text: $nameField)
                HStack(spacing: Spacing.lg) {
                    GhostInputField(
                        placeholder: "0",
                        text: $weightField,
                        suffix: "кг",
                        keyboardType: .decimalPad,
                        alignment: .center
                    )
                    GhostInputField(
                        placeholder: "0",
                        text: $repsField,
                        suffix: "повт",
                        keyboardType: .numberPad,
                        alignment: .center
                    )
                }
            }
        }
    }

    private var searchSection: some View {
        section(title: "SEARCH FIELD") {
            SearchField(
                placeholder: "Search 258 exercises...",
                text: $searchField,
                trailingMeta: "3K"
            )
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
            content()
        }
    }

    private func colorSwatch(_ color: Color, name: String) -> some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: Radii.sm)
                .fill(color)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: Radii.sm)
                        .strokeBorder(Color.App.outlineVariant.opacity(0.3), lineWidth: 1)
                )
            Text(name)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Component Catalog") {
    ComponentCatalog()
}
#endif
