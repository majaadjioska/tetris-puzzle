import SwiftUI
import GameKit

/// Presents Apple's native Game Center leaderboard UI.
struct GameCenterView: UIViewControllerRepresentable {
    var leaderboardID: String = GameCenterService.LeaderboardID.allTime

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let controller = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        controller.gameCenterDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            dismiss()
        }
    }
}
