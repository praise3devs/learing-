import SwiftUI

// MARK: - Activity View

struct ActivityView: View {

    // MARK: - Dependencies

    @EnvironmentObject var appData: AppData
    @EnvironmentObject var router: AppRouter
    @Environment(\.colorScheme) var colorScheme

    // MARK: - ViewModel

    @StateObject private var viewModel = ActivityViewModel()

    // MARK: - Body

    var body: some View {

        ZStack {

            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // MARK: Header

                HStack {

                    VStack(alignment: .leading, spacing: 4) {

                        Text("Activity")
                            .font(.system(size: 30, weight: .bold))

                        Text(viewModel.currentDate)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Calendar Button

                    Button {
                        viewModel.showCalendar = true
                    } label: {

                        Image(systemName: "calendar")
                            .font(.system(size: 19))
                            .frame(width: 45, height: 45)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .tint(.primary)

                    // Edit Goal Button

                    Button {
                        viewModel.showEditGoal = true
                    } label: {

                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 19))
                            .frame(width: 45, height: 45)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .tint(.primary)
                }

                // MARK: - Weekly Calendar

                HStack(spacing: 0) {

                    ForEach(viewModel.weekDates, id: \.self) { date in

                        let key = appData.dateKey(for: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        let isLearned = appData.learnedDays.contains(key)
                        let isFreezed = appData.freezedDays.contains(key)

                        VStack(spacing: 8) {

                            // Weekday

                            Text(date.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(size: 11))
                                .foregroundStyle(
                                    isToday ? .primary :
                                    isLearned ? Color.orange :
                                    isFreezed ? Color.cyan :
                                    .primary
                                )

                            // Day Number

                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    isToday ? .white :
                                    isLearned ? Color.orange :
                                    isFreezed ? Color.cyan :
                                    .primary
                                )
                                .frame(width: 38, height: 38)
                                .background {

                                    if isToday {

                                        Circle()
                                            .fill(Color.orange)

                                    } else if isLearned {

                                        Circle()
                                            .fill(Color.orange.opacity(0.16))

                                    } else if isFreezed {

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

                // MARK: Learned and Freezed Cards

                HStack(spacing: 12) {

                    countCard(
                        icon: "flame.fill",
                        iconColor: .orange,
                        count: appData.learnedCount,
                        title: "Learned"
                    )

                    countCard(
                        icon: "snowflake",
                        iconColor: .cyan,
                        count: appData.freezedCount,
                        title: "Freezed"
                    )
                }

                Spacer()

                // MARK: Learned Button

                Button {

                    viewModel.logAsLearned(appData: appData)

                } label: {

                    Text(
                        appData.isTodayLearned
                        ? "Logged as Learned"
                        : "Log as Learned"
                    )
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(
                        appData.isTodayLearned
                        ? Color.secondary
                        : Color.white
                    )
                    .frame(width: 272, height: 272)
                    .background {

                        if appData.isTodayLearned {

                            Circle()
                                .fill(.clear)
                                .glassEffect(
                                    .regular,
                                    in: Circle()
                                )

                        } else {

                            Circle()
                                .fill(Color.orange)
                        }
                    }
                    .overlay {

                        Circle()
                            .stroke(
                                Color.orange.opacity(0.25),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(!appData.isGoalActive)

                Spacer()

                // MARK: Freeze Button

                let canFreezeToday = viewModel.canFreeze(appData: appData)

                Button {

                    viewModel.freezeToday(appData: appData)

                } label: {

                    Text(viewModel.freezeButtonTitle(appData: appData))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            canFreezeToday ? .white : Color.secondary
                        )
                        .frame(width: 272, height: 36)
                        .padding(.vertical, 8)
                        .background {

                            if canFreezeToday {

                                Capsule()
                                    .fill(Color.cyan)

                            } else {

                                Capsule()
                                    .fill(.clear)
                                    .glassEffect(
                                        .regular,
                                        in: Capsule()
                                    )
                            }
                        }
                }
                .buttonStyle(.plain)
                .disabled(!canFreezeToday || !appData.isGoalActive)

                Text(
                    "\(appData.freezedCount) out of \(appData.freezeLimit) Freezes used"
                )
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 22)
            .padding(.top, 15)
            .padding(.bottom, 25)
        }

        // MARK: - Calendar Navigation

        .sheet(
            isPresented: $viewModel.showCalendar,
            onDismiss: {
                viewModel.verifyGoalStatus(appData: appData, router: router)
            }
        ) {

            CalendarView()
                .environmentObject(appData)
        }

        // MARK: - Edit Goal Navigation

        .sheet(isPresented: $viewModel.showEditGoal) {

            EditLearningGoalView()
                .environmentObject(appData)
        }

        // MARK: - Refresh Goal Status

        .onAppear {
            viewModel.verifyGoalStatus(appData: appData, router: router)
        }

        // MARK: - Automatic Goal Result

        .onChange(of: appData.isGoalActive) { _, isActive in

            if !isActive {
                viewModel.navigateToGoalResult(router: router)
            }
        }
    }

    // MARK: - Count Card

    func countCard(
        icon: String,
        iconColor: Color,
        count: Int,
        title: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 17, weight: .bold))

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .overlay {

            RoundedRectangle(cornerRadius: 23)
                .stroke(
                    Color.secondary.opacity(0.2),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ActivityView()
            .environmentObject(AppData())
            .environmentObject(AppRouter())
    }
}
