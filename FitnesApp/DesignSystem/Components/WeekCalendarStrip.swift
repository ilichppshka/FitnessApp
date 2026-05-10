import Foundation
import SwiftUI

struct WeekCalendarStrip: View {
    let week: [Date]
    @Binding var selectedDate: Date
    var today: Date = Date()
    var calendar: Calendar = .current
    var locale: Locale = .current

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(week, id: \.timeIntervalSinceReferenceDate) { date in
                DayCell(
                    weekdayLetter: weekdayLetter(for: date),
                    day: calendar.component(.day, from: date),
                    state: state(for: date),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    action: { selectedDate = date }
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekdayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date).uppercased()
    }

    private func state(for date: Date) -> DayCellState {
        if calendar.isDate(date, inSameDayAs: today) { return .today }
        if date < today { return .past }
        return .future
    }
}

#Preview("Week Calendar Strip") {
    @Previewable @State var selected: Date = Calendar.current
        .date(from: DateComponents(year: 2026, month: 4, day: 16))!

    let calendar = Calendar.current
    let today = calendar.date(from: DateComponents(year: 2026, month: 4, day: 16))!
    let week = (0..<7).compactMap { offset in
        calendar.date(byAdding: .day, value: offset - 3, to: today)
    }

    return VStack(spacing: Spacing.xl) {
        WeekCalendarStrip(
            week: week,
            selectedDate: $selected,
            today: today
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
