import SwiftUI

struct DashboardGreetingHeader: View {
    let dateLabel: String
    let greeting: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(dateLabel)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
            Text(greeting)
                .font(Font.App.headlineLg)
                .foregroundStyle(Color.App.onSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Dashboard Greeting Header") {
    VStack(spacing: Spacing.xl) {
        DashboardGreetingHeader(
            dateLabel: "THURSDAY · APR 16",
            greeting: "Hey, Alex"
        )
        DashboardGreetingHeader(
            dateLabel: "MONDAY · MAY 11",
            greeting: "Hey there"
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
