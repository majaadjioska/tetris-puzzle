import GameKit
import SwiftUI
import UIKit

/// Wraps Game Center authentication and score submission.
///
/// Setup required outside the code (see README / App Store Connect):
/// 1. Enable the "Game Center" capability on the app target in Xcode.
/// 2. Create three leaderboards in App Store Connect and set their IDs to
///    match `LeaderboardID` below (or change these strings to your IDs).
///    Recommended: `weekly` and `daily` as *recurring* leaderboards so Apple
///    resets them automatically; `alltime` as a classic leaderboard.
@MainActor
final class GameCenterService: ObservableObject {
    enum LeaderboardID {
        static let allTime = "block_puzzle_alltime"
        static let weekly = "block_puzzle_weekly"
        static let daily = "block_puzzle_daily"

        static var all: [String] { [allTime, weekly, daily] }
    }

    @Published private(set) var isAuthenticated = false
    @Published private(set) var lastError: String?

    /// Call once, early in the app lifecycle. Game Center invokes the handler
    /// again automatically if the auth state changes.
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }

            if let viewController {
                // Game Center needs to present its sign-in UI.
                Self.presentAuthUI(viewController)
                return
            }

            if let error {
                self.lastError = error.localizedDescription
                self.isAuthenticated = false
                return
            }

            self.lastError = nil
            self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
        }
    }

    /// Submit a final score to all leaderboards. No-op if not signed in.
    func submit(score: Int) {
        guard isAuthenticated, score > 0 else { return }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: LeaderboardID.all
        ) { error in
            if let error {
                #if DEBUG
                print("Game Center submit failed: \(error.localizedDescription)")
                #endif
            }
        }
    }

    private static func presentAuthUI(_ viewController: UIViewController) {
        guard let root = keyRootViewController() else { return }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        top.present(viewController, animated: true)
    }

    static func keyRootViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first

        return scene?.keyWindow?.rootViewController
    }
}
