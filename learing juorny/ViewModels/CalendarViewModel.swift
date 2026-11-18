import SwiftUI
import Combine

// MARK: - Calendar ViewModel

@MainActor
final class CalendarViewModel: ObservableObject {

    // MARK: - Calendar Settings

    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }

    let weekDays = [
        "SUN", "MON", "TUE", "WED",
        "THU", "FRI", "SAT"
    ]

    // MARK: - Months Range

    var months: [Date] {
        let start = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 1)
        )!

        let end = calendar.date(
            from: DateComponents(year: 2028, month: 12, day: 1)
        )!

        var result: [Date] = []
        var current = start

        while current <= end {
            result.append(current)

            guard let nextMonth = calendar.date(
                byAdding: .month,
                value: 1,
                to: current
            ) else {
                break
            }

            current = nextMonth
        }

        return result
    }

    // MARK: - Month Calculations

    func daysInMonth(for month: Date) -> [Date] {
        let components = calendar.dateComponents(
            [.year, .month],
            from: month
        )

        let numberOfDays = calendar.range(
            of: .day,
            in: .month,
            for: month
        )!.count

        let firstDay = calendar.date(from: components)!

        return (1...numberOfDays).compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            )
        }
    }

    func emptySpaces(for month: Date) -> Int {
        let components = calendar.dateComponents(
            [.year, .month],
            from: month
        )
        let firstDay = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        return firstWeekday - 1
    }
}
