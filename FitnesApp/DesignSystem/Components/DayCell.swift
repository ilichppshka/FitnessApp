import SwiftUI

enum DayCellState {
    case past
    case today
    case future
}

struct DayCell: View {
    let weekdayLetter: String
    let day: Int
    let state: DayCellState
    var isSelected: Bool = false
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: Spacing.xs) {
            Text(weekdayLetter)
                .font(Font.App.labelSm)
                .foregroundStyle(letterColor)

            Text("\(day)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(numberColor)
        }
        .frame(width: 36, height: 56)
        .background(
            RoundedRectangle(cornerRadius: Radii.sm)
                .fill(background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radii.sm)
                .strokeBorder(border, lineWidth: 1)
        )
    }

    private var letterColor: Color {
        switch state {
        case .past:   Color.App.onSurface.opacity(0.3)
        case .today:  isSelected ? Color.App.onPrimary.opacity(0.7) : Color.App.primary
        case .future: Color.App.onSurface.opacity(0.5)
        }
    }

    private var numberColor: Color {
        if isSelected { return Color.App.onPrimary }
        switch state {
        case .past:   return Color.App.onSurface.opacity(0.4)
        case .today:  return Color.App.primary
        case .future: return Color.App.onSurface
        }
    }

    private var background: Color {
        isSelected ? Color.App.primary : .clear
    }

    private var border: Color {
        if isSelected { return .clear }
        return state == .today ? Color.App.primary : Color.App.outlineVariant.opacity(0.3)
    }
}

#Preview("Day Cell") {
    HStack(spacing: Spacing.xs) {
        DayCell(weekdayLetter: "M", day: 13, state: .past)
        DayCell(weekdayLetter: "T", day: 14, state: .past)
        DayCell(weekdayLetter: "W", day: 15, state: .past)
        DayCell(weekdayLetter: "T", day: 16, state: .today, isSelected: true)
        DayCell(weekdayLetter: "F", day: 17, state: .future)
        DayCell(weekdayLetter: "S", day: 18, state: .future)
        DayCell(weekdayLetter: "S", day: 19, state: .future)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
