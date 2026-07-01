import SwiftUI

struct RootView: View {
    @EnvironmentObject var scoreStore: ScoreStore
    @EnvironmentObject var savedGameStore: SavedGameStore
    @StateObject private var game = GameState()
    @State private var screen: Screen = .home

    enum Screen: Hashable {
        case home
        case game
    }

    var body: some View {
        ZStack {
            switch screen {
            case .home:
                HomeView(
                    hasSavedGame: savedGameStore.hasUnfinishedGame,
                    savedScore: savedGameStore.savedScore,
                    onContinue: continueGame,
                    onNewGame: startNewGame
                )
                .transition(.opacity)
            case .game:
                GameView(
                    game: game,
                    onExit: exitToHome
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: screen)
    }

    private func continueGame() {
        if let snapshot = savedGameStore.load() {
            game.restore(from: snapshot)
        } else {
            game.newGame()
        }
        goTo(.game)
    }

    private func startNewGame() {
        savedGameStore.clear()
        game.newGame()
        goTo(.game)
    }

    private func exitToHome() {
        if game.isGameOver {
            savedGameStore.clear()
        } else {
            savedGameStore.save(game)
        }
        goTo(.home)
    }

    private func goTo(_ next: Screen) {
        withAnimation(.easeInOut(duration: 0.25)) {
            screen = next
        }
    }
}
