import SwiftUI

struct RangeTabs<Range: Hashable>: View {
    let ranges: [Range]
    @Binding var selection: Range
    let title: (Range) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ranges, id: \.self) { range in
                let isSelected = selection == range

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = range
                    }
                } label: {
                    Text(title(range))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            isSelected ? Color.App.onSurface : Color.App.onSurface.opacity(0.4)
                        )
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.App.surfaceContainerHigh : .clear)
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.App.outlineVariant : .clear,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Range Tabs") {
    enum DemoRange: String, CaseIterable, Hashable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3M"
        case year = "Year"
        case all = "All"
    }

    @Previewable @State var range: DemoRange = .month

    return VStack(spacing: Spacing.xl) {
        RangeTabs(
            ranges: DemoRange.allCases,
            selection: $range,
            title: { $0.rawValue }
        )

        Text("Selected: \(range.rawValue)")
            .font(Font.App.bodyMd)
            .foregroundStyle(Color.App.onSurface.opacity(0.6))
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
