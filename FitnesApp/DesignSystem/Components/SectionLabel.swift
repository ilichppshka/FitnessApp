import SwiftUI

struct SectionLabel: View {
    let text: String
    var opacity: Double = 0.5

    var body: some View {
        Text(text)
            .kineticText(.labelSm)
            .foregroundStyle(Color.App.onSurface.opacity(opacity))
    }
}

#Preview("Section Label") {
    VStack(alignment: .leading, spacing: Spacing.lg) {
        SectionLabel(text: "Next Session")
        SectionLabel(text: "This Week")
        SectionLabel(text: "Notifications & Feedback")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(Spacing.xl)
    .frame(maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
