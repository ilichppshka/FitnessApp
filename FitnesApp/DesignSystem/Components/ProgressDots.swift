import SwiftUI

struct ProgressDots: View {
    let total: Int
    let completed: Int
    var size: CGFloat = 6
    var spacing: CGFloat = Spacing.xs

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? Color.App.primary : Color.App.outlineVariant)
                    .frame(width: size, height: size)
            }
        }
    }
}

#Preview("Progress Dots") {
    VStack(spacing: Spacing.lg) {
        ProgressDots(total: 4, completed: 3)
        ProgressDots(total: 5, completed: 0)
        ProgressDots(total: 5, completed: 5, size: 8)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
