import SwiftUI
import Combine

// MARK: - Onboarding ViewModel

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var learningTopic: String = ""
    @Published var selectedDuration: String = "Week"

    let availableDurations: [String] = ["Week", "Month", "Year"]

    // MARK: - Actions

    func startLearning(appData: AppData, router: AppRouter) {
        let goal = learningTopic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty else { return }

        // Save Goal, Duration and Start Date
        appData.updateGoal(
            goal: goal,
            duration: selectedDuration
        )

        // Navigate to Activity
        router.path.append(AppRoute.activity)
    }
}
