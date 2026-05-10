import SwiftUI

enum DeltaDirection {
    case up
    case down

    var systemName: String {
        switch self {
        case .up:   "arrow.up"
        case .down: "arrow.down"
        }
    }
}

struct DeltaPill: View {
    let direction: DeltaDirection
    let value: String

    var body: some View {
        Chip(
            title: value,
            style: .delta,
            leadingSystemName: direction.systemName
        )
    }
}

#Preview("Delta Pill") {
    HStack(spacing: Spacing.lg) {
        DeltaPill(direction: .up, value: "+18.2%")
        DeltaPill(direction: .up, value: "+5kg")
        DeltaPill(direction: .down, value: "-2%")
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
