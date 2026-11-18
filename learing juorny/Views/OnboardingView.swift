import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {

    // MARK: - Dependencies

    @EnvironmentObject var appData: AppData
    @EnvironmentObject var router: AppRouter

    // MARK: - ViewModel

    @StateObject private var viewModel = OnboardingViewModel()

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {

                Spacer()

                // App Icon
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 67, height: 43)
                    .foregroundStyle(Color.orange)
                    .frame(maxWidth: .infinity)
                    .offset(y: -60)

                // Title
                HStack(spacing: 7) {
                    Text("Hello")
                        .font(.system(size: 28, weight: .regular))

                    Text("Learner")
                        .font(.system(size: 28, weight: .bold))
                }
                .foregroundStyle(.primary)

                Text("This app will help you learn everyday!")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Spacer()
                    .frame(height: 12)

                // Adding the Goal
                Text("I want to learn")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                TextField("swift", text: $viewModel.learningTopic)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                    }

                // Adding Time Period
                Text("I want to learn it in a")
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                HStack(spacing: 10) {
                    ForEach(viewModel.availableDurations, id: \.self) { duration in
                        if viewModel.selectedDuration == duration {
                            Button {
                                viewModel.selectedDuration = duration
                            } label: {
                                Text(duration)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                                    .frame(width: 70)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.orange)
                        } else {
                            Button {
                                viewModel.selectedDuration = duration
                            } label: {
                                Text(duration)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                                    .frame(width: 70)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.glass)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Start Learning Button
                Button {
                    viewModel.startLearning(appData: appData, router: router)
                } label: {
                    Text("Start Learning")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .frame(maxWidth: .infinity)

                Text("You can edit your desire later")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                Spacer()
                    .frame(height: 10)
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppData())
        .environmentObject(AppRouter())
}
