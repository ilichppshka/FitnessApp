#if DEBUG
import SwiftUI

private struct ComponentCatalog: View {
    @State private var nameField: String = ""
    @State private var weightField: String = "80"
    @State private var repsField: String = ""
    @State private var navTab: NavTab = .dashboard

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

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                    colorsSection
                    typographySection
                    glowSection
                    buttonsSection
                    cardsSection
                    inputsSection
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
                colorSwatch(Color.App.surfaceContainerLow, name: "container.low")
                colorSwatch(Color.App.surfaceContainerHigh, name: "container.high")
            }
            HStack(spacing: Spacing.sm) {
                colorSwatch(Color.App.primary, name: "primary")
                colorSwatch(Color.App.onPrimary, name: "onPrimary")
                colorSwatch(Color.App.onSurface, name: "onSurface")
                colorSwatch(Color.App.outlineVariant, name: "outline")
            }
        }
    }

    private var typographySection: some View {
        section(title: "TYPOGRAPHY") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("12 480 кг").font(Font.App.displayLg)
                Text("Push Day").font(Font.App.headlineLg)
                Text("Жим штанги").font(Font.App.titleLg)
                Text("Базовое движение для груди").font(Font.App.bodyMd)
                Text("ТОННАЖ ЗА НЕДЕЛЮ").font(Font.App.labelSm)
            }
        }
    }

    private var glowSection: some View {
        section(title: "NEON GLOW") {
            HStack(spacing: Spacing.lg) {
                Circle()
                    .fill(Color.App.primary)
                    .frame(width: 64, height: 64)
                    .neonGlow(radius: 20)
                Circle()
                    .fill(Color.App.primary)
                    .frame(width: 64, height: 64)
                    .neonGlow(radius: 8, opacity: 0.4)
                Circle()
                    .fill(Color.App.primary.opacity(0.4))
                    .frame(width: 64, height: 64)
                    .neonGlow(isActive: false)
            }
        }
    }

    private var buttonsSection: some View {
        section(title: "BUTTONS") {
            VStack(spacing: Spacing.sm) {
                KineticButton(title: "Quick Start", action: {})
                KineticButton(title: "Создать план", style: .secondary, action: {})
                KineticButton(title: "Disabled", isEnabled: false, action: {})
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
                PerformanceCard(action: {}) {
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
                }
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
