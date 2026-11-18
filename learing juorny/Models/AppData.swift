import SwiftUI
import Combine

// MARK: - Goal Status

enum GoalStatus: String, Codable {
    case active
    case completed
    case failed
}

// MARK: - Saved Data

private struct SavedAppData: Codable {

    var learningGoal: String
    var selectedDuration: String
    var goalStartDate: Date
    var goalStatus: GoalStatus

    var learnedDays: Set<String>
    var freezedDays: Set<String>
    var freezeActionDays: Set<String>

    var hasCreatedGoal: Bool?
}

// MARK: - AppData (Learning Model & Store)

class AppData: ObservableObject {

    private static let storageKey = "LearningJourneyData"

    // MARK: - Learning Goal

    @Published private(set) var hasCreatedGoal = false {
        didSet { saveData() }
    }

    @Published var learningGoal = "Swift" {
        didSet { saveData() }
    }

    @Published var selectedDuration = "Week" {
        didSet { saveData() }
    }

    @Published var goalStartDate = Date.now {
        didSet { saveData() }
    }

    @Published private(set) var goalStatus: GoalStatus = .active {
        didSet { saveData() }
    }

    // MARK: - Activity Dates

    @Published var learnedDays: Set<String> = [] {
        didSet { saveData() }
    }

    @Published var freezedDays: Set<String> = [] {
        didSet { saveData() }
    }

    @Published var freezeActionDays: Set<String> = [] {
        didSet { saveData() }
    }

    // MARK: - Initialization

    init() {
        loadData()
    }

    // MARK: - Save Data

    private func saveData() {

        let savedData = SavedAppData(
            learningGoal: learningGoal,
            selectedDuration: selectedDuration,
            goalStartDate: goalStartDate,
            goalStatus: goalStatus,
            learnedDays: learnedDays,
            freezedDays: freezedDays,
            freezeActionDays: freezeActionDays,
            hasCreatedGoal: hasCreatedGoal
        )

        if let encodedData = try? JSONEncoder().encode(savedData) {

            UserDefaults.standard.set(
                encodedData,
                forKey: Self.storageKey
            )
        }
    }

    // MARK: - Load Data

    private func loadData() {

        guard let savedData = UserDefaults.standard.data(
            forKey: Self.storageKey
        ) else {
            return
        }

        guard let decodedData = try? JSONDecoder().decode(
            SavedAppData.self,
            from: savedData
        ) else {
            return
        }

        learningGoal = decodedData.learningGoal
        selectedDuration = decodedData.selectedDuration
        goalStartDate = decodedData.goalStartDate
        goalStatus = decodedData.goalStatus

        learnedDays = decodedData.learnedDays
        freezedDays = decodedData.freezedDays
        freezeActionDays = decodedData.freezeActionDays

        hasCreatedGoal = decodedData.hasCreatedGoal ?? true
    }

    // MARK: - Return to Onboarding

    func returnToOnboarding() {
        hasCreatedGoal = false
    }

    // MARK: - Date Helpers

    func dateKey(for date: Date) -> String {

        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )

        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    var todayKey: String {
        dateKey(for: Date.now)
    }

    var yesterday: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Calendar.current.startOfDay(for: Date.now)
        )!
    }

    var yesterdayKey: String {
        dateKey(for: yesterday)
    }

    // MARK: - Goal Requirements

    var requiredLearnedDays: Int {

        switch selectedDuration {
        case "Week": return 7
        case "Month": return 30
        case "Year": return 365
        default: return 7
        }
    }

    // MARK: - Freeze Limit

    var freezeLimit: Int {

        switch selectedDuration {
        case "Week": return 2
        case "Month": return 8
        case "Year": return 96
        default: return 2
        }
    }

    var remainingFreezes: Int {
        max(0, freezeLimit - freezeActionDays.count)
    }

    var canUseFreeze: Bool {
        remainingFreezes > 0 &&
        !freezeActionDays.contains(todayKey)
    }

    // MARK: - Counts

    var learnedCount: Int {

        learnedDays.filter {
            $0 >= dateKey(for: goalStartDate)
        }.count
    }

    var freezedCount: Int {

        freezedDays.filter {
            $0 >= dateKey(for: goalStartDate)
        }.count
    }

    // MARK: - Today's Status

    var isTodayLearned: Bool {
        learnedDays.contains(todayKey)
    }

    var isTodayFreezed: Bool {
        freezedDays.contains(todayKey)
    }

    // MARK: - Rescue Window

    var isInRescueWindow: Bool {

        let hour = Calendar.current.component(
            .hour,
            from: Date.now
        )

        return hour < 8
    }

    var canRescueYesterday: Bool {

        guard isInRescueWindow else { return false }

        let startKey = dateKey(for: goalStartDate)

        guard yesterdayKey >= startKey else { return false }

        return !learnedDays.contains(yesterdayKey) &&
               !freezedDays.contains(yesterdayKey)
    }

    // MARK: - Goal Status

    var isGoalActive: Bool {
        goalStatus == .active
    }

    var isGoalCompleted: Bool {
        goalStatus == .completed
    }

    var isGoalFailed: Bool {
        goalStatus == .failed
    }

    // MARK: - Refresh Goal Status

    func refreshGoalStatus(now: Date = Date.now) {

        guard goalStatus == .active else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let hour = calendar.component(.hour, from: now)

        let lastDayToCheck: Date

        if hour < 8 {

            lastDayToCheck = calendar.date(
                byAdding: .day,
                value: -2,
                to: today
            )!

        } else {

            lastDayToCheck = calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            )!
        }

        var date = calendar.startOfDay(for: goalStartDate)

        while date <= lastDayToCheck {

            let key = dateKey(for: date)

            let hasLearned = learnedDays.contains(key)
            let hasFreeze = freezedDays.contains(key)

            if !hasLearned && !hasFreeze {
                goalStatus = .failed
                return
            }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            ) else {
                break
            }

            date = nextDate
        }

        if learnedCount >= requiredLearnedDays {
            goalStatus = .completed
        }
    }

    // MARK: - Log Learned

    func logAsLearned() {

        refreshGoalStatus()

        guard goalStatus == .active else { return }

        if freezedDays.remove(todayKey) != nil {
            freezeActionDays.remove(todayKey)
        }

        learnedDays.insert(todayKey)

        refreshGoalStatus()
    }

    // MARK: - Use Freeze

    func freezeToday() {

        refreshGoalStatus()

        guard goalStatus == .active else { return }
        guard canUseFreeze else { return }

        if learnedDays.remove(todayKey) != nil {
            freezedDays.insert(todayKey)

        } else if canRescueYesterday {

            freezedDays.insert(yesterdayKey)

        } else {

            guard !freezedDays.contains(todayKey) else { return }

            freezedDays.insert(todayKey)
        }

        freezeActionDays.insert(todayKey)

        refreshGoalStatus()
    }

    // MARK: - Reset Goal

    func updateGoal(goal: String, duration: String) {

        learningGoal = goal
        selectedDuration = duration

        goalStartDate = Calendar.current.startOfDay(
            for: Date.now
        )

        learnedDays.removeAll()
        freezedDays.removeAll()
        freezeActionDays.removeAll()

        goalStatus = .active
        hasCreatedGoal = true
    }
}
