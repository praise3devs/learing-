import SwiftUI
import Combine

// MARK: - Goal Result ViewModel

@MainActor
final class GoalResultViewModel: ObservableObject {

    // MARK: - Published State

    @Published var showCalendar: Bool = false

    // MARK: - Weekly Dates

    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)

        let start = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: today
        )!

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    // MARK: - Actions

    func setAnotherGoal(appData: AppData, router: AppRouter) {
        appData.returnToOnboarding()
        router.path = NavigationPath()
    }
}
