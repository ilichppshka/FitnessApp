import Foundation

extension Calendar {
    static let iso8601: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }()

    static func startOfDay(_ date: Date) -> Date {
        Self.iso8601.startOfDay(for: date)
    }

    static func iso8601WeekRange(reference: Date) -> ClosedRange<Date> {
        let calendar = Self.iso8601
        let weekday = calendar.component(.weekday, from: reference)
        let mondayOffset = ((weekday - calendar.firstWeekday) + 7) % 7
        let dayStart = calendar.startOfDay(for: reference)
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: dayStart),
              let endOfSunday = calendar.date(byAdding: .second, value: 7 * 86_400 - 1, to: monday) else {
            return dayStart...dayStart
        }
        return monday...endOfSunday
    }

    static func iso8601MonthRange(reference: Date) -> ClosedRange<Date> {
        let calendar = Self.iso8601
        guard let monthInterval = calendar.dateInterval(of: .month, for: reference) else {
            let day = calendar.startOfDay(for: reference)
            return day...day
        }
        let endInclusive = monthInterval.end.addingTimeInterval(-1)
        return monthInterval.start...endInclusive
    }

    // MARK: - DateRange → ClosedRange

    static func range(for dateRange: DateRange, now: Date = .now) -> ClosedRange<Date> {
        let calendar = Self.iso8601
        switch dateRange {
        case .week:
            return iso8601WeekRange(reference: now)
        case .month:
            return iso8601MonthRange(reference: now)
        case .threeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: startOfDay(now)) ?? now
            return start...now
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: startOfDay(now)) ?? now
            return start...now
        case .all:
            return Date.distantPast...now
        }
    }

    static func previousRange(for dateRange: DateRange, now: Date = .now) -> ClosedRange<Date>? {
        let calendar = Self.iso8601
        switch dateRange {
        case .week:
            guard let prevRef = calendar.date(byAdding: .weekOfYear, value: -1, to: now) else { return nil }
            return iso8601WeekRange(reference: prevRef)
        case .month:
            guard let prevRef = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
            return iso8601MonthRange(reference: prevRef)
        case .threeMonths:
            let current = range(for: .threeMonths, now: now)
            let prevEnd = current.lowerBound.addingTimeInterval(-1)
            guard let prevStart = calendar.date(byAdding: .month, value: -3, to: current.lowerBound) else { return nil }
            return prevStart...prevEnd
        case .year:
            let current = range(for: .year, now: now)
            let prevEnd = current.lowerBound.addingTimeInterval(-1)
            guard let prevStart = calendar.date(byAdding: .year, value: -1, to: current.lowerBound) else { return nil }
            return prevStart...prevEnd
        case .all:
            return nil
        }
    }
}

extension ClosedRange where Bound == Date {
    var allDays: [Date] {
        let calendar = Calendar.iso8601
        var result: [Date] = []
        var cursor = calendar.startOfDay(for: lowerBound)
        let end = calendar.startOfDay(for: upperBound)
        while cursor <= end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }
}
