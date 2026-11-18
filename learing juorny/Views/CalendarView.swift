import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {

    // MARK: - Shared AppData

    @EnvironmentObject var appData: AppData

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - ViewModel

    @StateObject private var viewModel = CalendarViewModel()

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

    // MARK: - Date Key

    private func dateKey(_ date: Date) -> String {
        appData.dateKey(for: date)
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // Header

            ZStack {

                Text("Activities")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(primaryTextColor)

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(primaryTextColor)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle().fill(.ultraThinMaterial)
                            )
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)

            // Calendar Scroll

            ScrollView(.vertical) {

                LazyVStack(spacing: 0) {

                    ForEach(viewModel.months, id: \.self) { month in
                        monthView(month)
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
    }

    // MARK: - Month View

    private func monthView(_ month: Date) -> some View {

        let emptySpaces = viewModel.emptySpaces(for: month)
        let days = viewModel.daysInMonth(for: month)

        return VStack(alignment: .leading, spacing: 12) {

            // Month Title

            Text(month.formatted(
                .dateTime.month(.wide).year()
            ))
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(primaryTextColor)
            .padding(.top, 16)

            // Week Days

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 4),
                    count: 7
                ),
                spacing: 8
            ) {

                ForEach(viewModel.weekDays, id: \.self) { day in

                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(secondaryTextColor)
                        .frame(maxWidth: .infinity)
                }
            }

            // Dates

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 4),
                    count: 7
                ),
                spacing: 8
            ) {

                // Empty Spaces

                ForEach(0..<emptySpaces, id: \.self) { _ in

                    Color.clear
                        .frame(height: 36)
                }

                // Month Days

                ForEach(days, id: \.self) { date in
                    dayView(date)
                }
            }

            // Divider

            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.7)
                .padding(.top, 4)
        }
        .padding(.bottom, 10)
    }

    // MARK: - Day View

    private func dayView(_ date: Date) -> some View {

        let key = dateKey(date)

        let isToday = viewModel.calendar.isDateInToday(date)

        let isLearned = appData.learnedDays.contains(key)

        let isFreezed = appData.freezedDays.contains(key)

        return Text("\(viewModel.calendar.component(.day, from: date))")

            .font(.system(size: 17, weight: .regular))

            .foregroundStyle(
                isToday ? Color.white :
                isLearned ? Color.orange :
                isFreezed ? Color.cyan :
                primaryTextColor
            )

            .frame(width: 36, height: 36)

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

            .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {

    CalendarView()
        .environmentObject(AppData())
}
