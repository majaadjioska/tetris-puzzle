import SwiftUI

struct GameOverOverlay: View {
    @EnvironmentObject var scoreStore: ScoreStore
    let score: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Game Over")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Text("No more pieces fit on the board")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 18)

                    VStack(spacing: 2) {
                        Text("Final score")
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                        Text("\(score)")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .contentTransition(.numericText())
                    }

                    if isPersonalBest {
                        Label("New personal best!", systemImage: "sparkles")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.accentDeep)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(Theme.accent.opacity(0.16))
                            )
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

                    VStack(spacing: 10) {
                        Button(action: onPlayAgain) {
                            Text("Play again")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.accent, Theme.accentDeep],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .foregroundStyle(.white)
                        }

                        Button(action: onHome) {
                            Text("Back to menu")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Theme.accent, lineWidth: 1.5)
                                )
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Theme.surface)
                        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                )
                .padding(.horizontal, 18)
                .padding(.vertical, 30)
            }
        }
    }

    private var isPersonalBest: Bool {
        let allScores = scoreStore.scores.map(\.score)
        guard !allScores.isEmpty else { return score > 0 }
        return score >= (allScores.max() ?? 0) && score > 0
    }
}
