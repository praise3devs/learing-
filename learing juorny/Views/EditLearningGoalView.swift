import SwiftUI

// MARK: - Edit Learning Goal View

struct EditLearningGoalView: View {

    // MARK: - Dependencies

    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - ViewModel

    @StateObject private var viewModel = EditLearningGoalViewModel()

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : .secondary
    }

    private var dividerColor: Color {
        colorScheme == .dark
        ? .white.opacity(0.15)
        : .black.opacity(0.15)
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // Header

            ZStack {

                Text("Learning Goal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(primaryTextColor)

                HStack {

                    Button {
                        dismiss()
                    } label: {

                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primaryTextColor)
                            .frame(width: 42, height: 42)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }

                    Spacer()

                    Button {
                        viewModel.showUpdateAlert = true
                    } label: {

                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.orange, in: Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Goal Content

            VStack(alignment: .leading, spacing: 0) {

                Text("I want to learn")
                    .font(.system(size: 15))
                    .foregroundStyle(primaryTextColor)
                    .padding(.top, 42)

                TextField("Swift", text: $viewModel.learningGoal)
                    .font(.system(size: 16))
                    .foregroundStyle(primaryTextColor)
                    .tint(.orange)
                    .padding(.top, 14)
                    .padding(.bottom, 14)

                Rectangle()
                    .fill(dividerColor)
                    .frame(height: 1)

                Text("I want to learn it in a")
                    .font(.system(size: 15))
                    .foregroundStyle(primaryTextColor)
                    .padding(.top, 30)

                // Duration Buttons

                HStack(spacing: 12) {

                    ForEach(viewModel.durations, id: \.self) { duration in

                        Button {

                            viewModel.selectedDuration = duration

                        } label: {

                            Text(duration)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(
                                    viewModel.selectedDuration == duration
                                    ? .white
                                    : secondaryTextColor
                                )
                                .frame(width: 82, height: 46)
                                .background {

                                    if viewModel.selectedDuration == duration {

                                        Capsule()
                                            .fill(Color.orange)

                                    } else {

                                        Capsule()
                                            .fill(.clear)
                                            .glassEffect(
                                                .regular,
                                                in: Capsule()
                                            )
                                    }
                                }
                                .overlay {

                                    if viewModel.selectedDuration == duration {

                                        Capsule()
                                            .stroke(
                                                Color.orange.opacity(0.8),
                                                lineWidth: 1
                                            )
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())

        // Load Saved Values

        .onAppear {
            viewModel.loadInitialValues(from: appData)
        }

        // Update Alert

        .alert("Update goal", isPresented: $viewModel.showUpdateAlert) {

            Button("Dismiss", role: .cancel) {
            }

            Button("Update") {
                viewModel.updateGoal(appData: appData) {
                    dismiss()
                }
            }

        } message: {

            Text("Updating your goal will reset your progress and Freeze balance. Are you sure?")
        }
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        EditLearningGoalView()
            .environmentObject(AppData())
    }
}
