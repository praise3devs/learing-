

import SwiftUI
import Combine

enum AppRoute: Hashable {
    case activity
    case goalResult
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
}

@main
struct MyApp: App {

    @StateObject private var appData = AppData()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {

            NavigationStack(path: $router.path) {

                Group {
                    if !appData.hasCreatedGoal {
                        OnboardingView()

                    } else if appData.isGoalActive {
                        ActivityView()

                    } else {
                        GoalResultView(
                            goalCompleted: appData.isGoalCompleted
                        )
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in

                    switch route {

                    case .activity:
                        ActivityView()

                    case .goalResult:
                        GoalResultView(
                            goalCompleted: appData.isGoalCompleted
                        )
                    }
                }
            }
            .environmentObject(appData)
            .environmentObject(router)
        }
    }
}
