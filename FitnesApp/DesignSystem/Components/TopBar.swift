import SwiftUI

struct TopBar<Leading: View, Center: View, Trailing: View>: View {
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var center: () -> Center
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        ZStack {
            HStack {
                leading()
                Spacer()
                trailing()
            }

            center()
        }
        .frame(height: 44)
        .padding(.horizontal, Spacing.lg)
    }
}

extension TopBar where Center == EmptyView {
    init(
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.init(leading: leading, center: { EmptyView() }, trailing: trailing)
    }
}

extension TopBar where Trailing == EmptyView {
    init(
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.init(leading: leading, center: center, trailing: { EmptyView() })
    }
}

extension TopBar where Leading == EmptyView, Trailing == EmptyView {
    init(@ViewBuilder center: @escaping () -> Center) {
        self.init(leading: { EmptyView() }, center: center, trailing: { EmptyView() })
    }
}

#Preview("Top Bar") {
    VStack(spacing: Spacing.xl) {
        TopBar(
            leading: { IconChip(systemName: "chevron.left", action: {}) },
            trailing: {
                TextButton(
                    title: "Save Draft",
                    style: .pill,
                    foreground: Color.App.onSurface,
                    action: {}
                )
            }
        )

        TopBar(
            leading: { IconChip(systemName: "xmark", action: {}) },
            center: {
                VStack(spacing: 0) {
                    Text("SESSION")
                        .font(Font.App.labelSm)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    Text("24:18")
                        .font(Font.App.titleLg)
                }
            },
            trailing: { IconChip(systemName: "ellipsis", action: {}) }
        )

        TopBar(
            leading: { IconChip(systemName: "chevron.left", action: {}) },
            trailing: { IconChip(systemName: "arrow.down.to.line", action: {}) }
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
