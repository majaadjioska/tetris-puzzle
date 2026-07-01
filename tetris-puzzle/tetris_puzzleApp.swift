import SwiftUI

@main
struct tetris_puzzleApp: App {
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var savedGameStore = SavedGameStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(scoreStore)
                .environmentObject(savedGameStore)
                .preferredColorScheme(.light)
        }
    }
}
