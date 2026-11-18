import SwiftUI
import Combine

// MARK: - Edit Learning Goal ViewModel

@MainActor
final class EditLearningGoalViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var learningGoal: String = ""
    @Published var selectedDuration: String = "Week"
    @Published var showUpdateAlert: Bool = false

    let durations: [String] = ["Week", "Month", "Year"]

    // MARK: - Lifecycle

    func loadInitialValues(from appData: AppData) {
        learningGoal = appData.learningGoal
        selectedDuration = appData.selectedDuration
    }

    // MARK: - Actions

    func updateGoal(appData: AppData, onSuccess: () -> Void) {
        let newGoal = learningGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newGoal.isEmpty else { return }

        // Update Goal
        appData.updateGoal(
            goal: newGoal,
            duration: selectedDuration
        )

        // Close Page
        onSuccess()
    }
}
