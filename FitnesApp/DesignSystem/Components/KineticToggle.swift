import SwiftUI

/// Spec §5: custom toggle track. OFF = surfaceContainerHighest, ON = primary + neon glow.
struct KineticToggle: View {
    @Binding var isOn: Bool

    private let trackWidth: CGFloat = 44
    private let trackHeight: CGFloat = 26
    private let knobSize: CGFloat = 20
    private let knobPadding: CGFloat = 3

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            // Track
            Capsule()
                .fill(isOn ? Color.App.primary : Color.App.surfaceContainerHighest)
                .neonGlow(opacity: isOn ? 0.45 : 0, isActive: isOn)
                .frame(width: trackWidth, height: trackHeight)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)

            // Knob
            Circle()
                .fill(isOn ? Color.App.onPrimary : Color.App.onSurfaceMuted)
                .frame(width: knobSize, height: knobSize)
                .padding(knobPadding)
        }
        .frame(width: trackWidth, height: trackHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }
    }
}

#Preview("Kinetic Toggle") {
    @Previewable @State var on: Bool = true
    @Previewable @State var off: Bool = false

    return VStack(spacing: Spacing.lg) {
        HStack {
            Text("ON").kineticText(.labelSm).foregroundStyle(Color.App.onSurfaceMuted)
            Spacer()
            KineticToggle(isOn: $on)
        }
        HStack {
            Text("OFF").kineticText(.labelSm).foregroundStyle(Color.App.onSurfaceMuted)
            Spacer()
            KineticToggle(isOn: $off)
        }
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
