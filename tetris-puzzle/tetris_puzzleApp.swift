import SwiftUI

@main
struct tetris_puzzleApp: App {
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var savedGameStore = SavedGameStore()
    @StateObject private var gameCenter = GameCenterService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(scoreStore)
                .environmentObject(savedGameStore)
                .environmentObject(gameCenter)
                .preferredColorScheme(.dark)
                .task { gameCenter.authenticate() }
        }
    }
}
