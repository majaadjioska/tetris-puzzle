import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scoreStore: ScoreStore
    let hasSavedGame: Bool
    let savedScore: Int
    let onContinue: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    titleBlock
                        .padding(.top, 24)

                    if hasSavedGame {
                        savedGameActions
                    } else {
                        newGameButton(title: "Play", icon: "play.fill", action: onNewGame)
                    }

                    ScoreboardView(
                        title: "Today's best",
                        entries: scoreStore.topToday,
                        formatter: ScoreFormatters.dayTime
                    )

                    ScoreboardView(
                        title: "This week's best",
                        entries: scoreStore.topThisWeek,
                        formatter: ScoreFormatters.weekDay
                    )

                    ScoreboardView(
                        title: "All-time best",
                        entries: scoreStore.topAllTime,
                        formatter: ScoreFormatters.allTime,
                        highlight: Theme.accentDeep
                    )

                    Text("Drag a piece onto the 9×9 board. Clear full rows, columns, or 3×3 blocks. Game ends when no piece fits.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }

    private var savedGameActions: some View {
        VStack(spacing: 10) {
            newGameButton(title: "Continue", icon: "play.fill", action: onContinue)

            Text("Saved game · score \(savedScore)")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)

            Button(action: onNewGame) {
                Text("Start new game")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.accent, lineWidth: 1.5)
                    )
                    .foregroundStyle(Theme.accentDeep)
            }
            .padding(.horizontal, 4)
        }
    }

    private func newGameButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title)
                    .font(.title3.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accentDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Theme.accent.opacity(0.35), radius: 12, x: 0, y: 6)
            )
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Theme.accent)

            Text("Block Puzzle")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("A calm 9×9 block game")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
