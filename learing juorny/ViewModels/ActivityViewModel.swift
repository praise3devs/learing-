import SwiftUI
import Combine

// MARK: - Activity ViewModel

@MainActor
final class ActivityViewModel: ObservableObject {

    // MARK: - Published Navigation / Sheet State

    @Published var didNavigateToGoalResult: Bool = false
    @Published var showCalendar: Bool = false
    @Published var showEditGoal: Bool = false

    // MARK: - Computed Date Info

    var currentDate: String {
        Date.now.formatted(
            .dateTime.weekday(.wide).day().month(.wide)
        )
    }

    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date.now
        let weekday = calendar.component(.weekday, from: today)
        let firstDay = calendar.firstWeekday
        let difference = (weekday - firstDay + 7) % 7

        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -difference,
            to: calendar.startOfDay(for: today)
        )!

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: startOfWeek
            )
        }
    }

    // MARK: - Freeze Condition

    func canFreeze(appData: AppData) -> Bool {
        guard appData.canUseFreeze else { return false }

        if appData.canRescueYesterday {
            return true
        }

        return !appData.isTodayFreezed
    }

    // MARK: - Freeze Button Title

    func freezeButtonTitle(appData: AppData) -> String {
        if appData.freezeActionDays.contains(appData.todayKey) {
            return "Freezed for a day"
        }

        if appData.canRescueYesterday {
            return "Rescue yesterday with Freeze"
        }

        if appData.isTodayFreezed {
            return "Freezed for a day"
        }

        return "Freeze for a day"
    }

    // MARK: - Navigation & Status Verification

    func verifyGoalStatus(appData: AppData, router: AppRouter) {
        appData.refreshGoalStatus()

        if !appData.isGoalActive {
            navigateToGoalResult(router: router)
        }
    }

    func navigateToGoalResult(router: AppRouter) {
        guard !didNavigateToGoalResult else { return }
        didNavigateToGoalResult = true
        router.path.append(AppRoute.goalResult)
    }

    // MARK: - User Actions

    func logAsLearned(appData: AppData) {
        appData.logAsLearned()
    }

    func freezeToday(appData: AppData) {
        appData.freezeToday()
    }
}
