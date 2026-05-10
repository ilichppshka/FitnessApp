import SwiftUI

struct KineticToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .tint(Color.App.primary)
    }
}

#Preview("Kinetic Toggle") {
    @Previewable @State var on: Bool = true
    @Previewable @State var off: Bool = false

    return VStack(spacing: Spacing.lg) {
        KineticToggle(isOn: $on)
        KineticToggle(isOn: $off)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
