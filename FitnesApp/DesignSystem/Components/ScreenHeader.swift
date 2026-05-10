import SwiftUI

struct ScreenHeader: View {
    let label: String
    let title: String
    var accent: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionLabel(text: label)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                Text(title)
                    .font(Font.App.headlineLg)
                    .foregroundStyle(Color.App.onSurface)

                if let accent {
                    Text(accent)
                        .font(Font.App.headlineLg)
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }
}

#Preview("Screen Header") {
    VStack(alignment: .leading, spacing: Spacing.xl) {
        ScreenHeader(label: "Library", title: "Exercises", accent: "258")
        ScreenHeader(label: "Profile", title: "Settings")
        ScreenHeader(label: "Analytics", title: "Progress")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(Spacing.xl)
    .frame(maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
