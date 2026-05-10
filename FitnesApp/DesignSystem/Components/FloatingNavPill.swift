import SwiftUI

struct FloatingNavPill<Tab: Hashable & CaseIterable>: View {
    @Binding var selection: Tab
    let icon: (Tab) -> Image
    var title: ((Tab) -> String?)?

    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(Tab.allCases), id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(Spacing.xs)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.App.outlineVariant.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 18, y: 10)
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selection == tab
        let activeTitle = isSelected ? title?(tab) : nil

        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                selection = tab
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                icon(tab)
                    .font(.system(size: 18, weight: .semibold))

                if let activeTitle {
                    Text(activeTitle)
                        .font(Font.App.labelSm)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(isSelected ? Color.App.onPrimary : Color.App.onSurface.opacity(0.7))
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(selectionBackground(isSelected: isSelected))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func selectionBackground(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(Color.App.primary)
                .matchedGeometryEffect(id: "pill", in: pillNamespace)
        }
    }
}

private enum DemoTab: String, CaseIterable, Hashable {
    case dashboard
    case library
    case builder
    case progress
    case settings

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
        case .library: "УПРАЖНЕНИЯ"
        case .builder: "ПЛАНЫ"
        case .progress: "ПРОГРЕСС"
        case .settings: "НАСТРОЙКИ"
        }
    }
}

#Preview("Floating Nav Pill") {
    @Previewable @State var selection: DemoTab = .dashboard

    return ZStack(alignment: .bottom) {
        Color.App.surface
            .overlay(
                LinearGradient(
                    colors: [Color.App.primary.opacity(0.15), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea()

        FloatingNavPill(
            selection: $selection,
            icon: { Image(systemName: $0.systemImage) },
            title: { $0.label }
        )
        .padding(.bottom, Spacing.lg)
    }
    .preferredColorScheme(.dark)
}
