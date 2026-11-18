import SwiftUI

// MARK: - Goal Result View

struct GoalResultView: View {

    // true = Goal Completed
    // false = Goal Not Met
    let goalCompleted: Bool

    // MARK: - Dependencies

    @EnvironmentObject var appData: AppData
    @EnvironmentObject var router: AppRouter
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - ViewModel

    @StateObject private var viewModel = GoalResultViewModel()

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

    private var cardBorderColor: Color {
        colorScheme == .dark
        ? .white.opacity(0.15)
        : .black.opacity(0.12)
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Status Bar Space

            HStack {
                Spacer()
            }
            .padding(.top, 8)

            // MARK: - Header

            HStack {

                Text("Activity")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                // Calendar Button

                Button {
                    viewModel.showCalendar = true
                } label: {

                    Image(systemName: "calendar")
                        .font(.system(size: 19))
                        .foregroundStyle(primaryTextColor)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)

                // Edit Goal Button - Disabled

                Button {

                } label: {

                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 19))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // MARK: - Date

            HStack {

                Text(Date.now.formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                ))
                .font(.system(size: 14))
                .foregroundStyle(secondaryTextColor)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)

            // MARK: - Weekly Calendar

            HStack(spacing: 0) {

                ForEach(viewModel.weekDates, id: \.self) { date in

                    VStack(spacing: 8) {

                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 11))
                            .foregroundStyle(primaryTextColor)

                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.system(size: 16))
                            .foregroundStyle(dayColor(for: date))
                            .frame(width: 38, height: 38)
                            .background {

                                if Calendar.current.isDateInToday(date) {

                                    Circle()
                                        .fill(Color.orange)

                                } else if learnedDays.contains(appData.dateKey(for: date)) {

                                    Circle()
                                        .fill(Color.orange.opacity(0.16))

                                } else if freezedDays.contains(appData.dateKey(for: date)) {

                                    Circle()
                                        .fill(Color.cyan.opacity(0.16))
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)

            // MARK: - Statistics Cards

            HStack(spacing: 10) {

                statCard(
                    icon: "flame.fill",
                    number: "\(appData.learnedCount) \(appData.learnedCount == 1 ? "day" : "days")",
                    title: "Learned",
                    color: .orange
                )

                statCard(
                    icon: "snowflake",
                    number: "\(appData.freezedCount) \(appData.freezedCount == 1 ? "day" : "days")",
                    title: "Freezed",
                    color: .cyan
                )
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            Spacer()

            // MARK: - Goal Result

            VStack(spacing: 12) {

                Image(
                    systemName: goalCompleted
                    ? "hands.clap.fill"
                    : "xmark.seal.fill"
                )
                .font(.system(size: 42))
                .foregroundStyle(.orange)

                Text(
                    goalCompleted
                    ? "Well done!"
                    : "You didn't reach your goal this time."
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.center)

                Text(
                    goalCompleted
                    ? "Ready for your next goal?"
                    : "Want to set another goal?"
                )
                .font(.system(size: 13))
                .foregroundStyle(secondaryTextColor)
            }
            .padding(.horizontal, 20)

            // MARK: - Set a Goal Button

            Button {
                viewModel.setAnotherGoal(appData: appData, router: router)
            } label: {

                HStack(spacing: 6) {

                    Image(systemName: "timer")
                        .font(.system(size: 15))

                    Text("Set a goal")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(height: 46)
                .background(Color.orange, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 64)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())

        // MARK: - Calendar Navigation

        .sheet(isPresented: $viewModel.showCalendar) {

            CalendarView()
                .environmentObject(appData)
        }
    }

    // MARK: - Statistics Card

    private func statCard(
        icon: String,
        number: String,
        title: String,
        color: Color
    ) -> some View {

        VStack(spacing: 6) {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(number)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(primaryTextColor)

            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(primaryTextColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background {

            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        }
        .overlay {

            RoundedRectangle(cornerRadius: 28)
                .stroke(cardBorderColor, lineWidth: 1)
        }
    }

    // MARK: - AppData Dates

    private var learnedDays: Set<String> {
        appData.learnedDays
    }

    private var freezedDays: Set<String> {
        appData.freezedDays
    }

    // MARK: - Day Color

    private func dayColor(for date: Date) -> Color {

        if Calendar.current.isDateInToday(date) {

            return .white

        } else if learnedDays.contains(appData.dateKey(for: date)) {

            return .orange

        } else if freezedDays.contains(appData.dateKey(for: date)) {

            return .cyan

        } else {

            return primaryTextColor
        }
    }
}

// MARK: - Preview

#Preview("Goal Completed") {

    GoalResultView(goalCompleted: true)
        .environmentObject(AppData())
        .environmentObject(AppRouter())
}

#Preview("Goal Not Met") {

    GoalResultView(goalCompleted: false)
        .environmentObject(AppData())
        .environmentObject(AppRouter())
}
