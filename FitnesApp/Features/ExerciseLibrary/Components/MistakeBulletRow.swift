import SwiftUI

struct MistakeBulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: 22, height: 22)
            Text(text)
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Mistake Bullet Row") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        MistakeBulletRow(text: "Hip drive — using momentum instead of chest muscles to press the bar.")
        MistakeBulletRow(text: "Flared elbows — arms at 90° puts excessive stress on shoulder joints.")
        MistakeBulletRow(text: "Bouncing — letting the bar bounce off the chest removes muscle tension.")
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
#endif
