import SwiftUI

struct ProgressPillBar: View {
    let total: Int
    let currentIndex: Int
    var width: CGFloat = 72
    var height: CGFloat = 6

    private var segmentWidth: CGFloat {
        guard total > 0 else { return width }
        return width / CGFloat(total)
    }

    private var clampedIndex: CGFloat {
        CGFloat(max(0, min(currentIndex, total - 1)))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.App.outlineVariant.opacity(0.45))
                .frame(width: width, height: height)

            Capsule()
                .fill(Color.App.primary)
                .frame(width: segmentWidth, height: height)
                .offset(x: segmentWidth * clampedIndex)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentIndex)
        }
        .frame(width: width, height: height)
    }
}

#Preview("Progress Pill Bar") {
    struct Demo: View {
        @State private var index = 0
        var body: some View {
            VStack(spacing: Spacing.xl) {
                ProgressPillBar(total: 3, currentIndex: index)
                ProgressPillBar(total: 4, currentIndex: index, width: 96)
                Button("Next") {
                    index = (index + 1) % 4
                }
                .foregroundStyle(Color.App.primary)
            }
        }
    }
    return Demo()
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.surface)
        .preferredColorScheme(.dark)
}
