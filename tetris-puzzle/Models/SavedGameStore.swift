import Foundation

struct SavedGameSnapshot: Codable, Equatable {
    var board: [[BoardCell]]
    var trayPieces: [Piece?]
    var score: Int
    var consecutiveClearStreak: Int = 0

    enum CodingKeys: String, CodingKey {
        case board, trayPieces, score, consecutiveClearStreak
    }

    init(board: [[BoardCell]], trayPieces: [Piece?], score: Int, consecutiveClearStreak: Int = 0) {
        self.board = board
        self.trayPieces = trayPieces
        self.score = score
        self.consecutiveClearStreak = consecutiveClearStreak
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        board = try container.decode([[BoardCell]].self, forKey: .board)
        trayPieces = try container.decode([Piece?].self, forKey: .trayPieces)
        score = try container.decode(Int.self, forKey: .score)
        consecutiveClearStreak = try container.decodeIfPresent(Int.self, forKey: .consecutiveClearStreak) ?? 0
    }
}

final class SavedGameStore: ObservableObject {
    private static let storageKey = "jadeku.saved_game.v1"

    @Published private(set) var hasUnfinishedGame = false
    @Published private(set) var savedScore = 0

    init() {
        refreshMetadata()
    }

    func save(_ game: GameState) {
        guard !game.isGameOver else {
            clear()
            return
        }

        let snapshot = game.snapshot()
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        hasUnfinishedGame = true
        savedScore = snapshot.score
    }

    func load() -> SavedGameSnapshot? {
        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let snapshot = try? JSONDecoder().decode(SavedGameSnapshot.self, from: data)
        else { return nil }
        return snapshot
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        hasUnfinishedGame = false
        savedScore = 0
    }

    private func refreshMetadata() {
        guard let snapshot = load() else {
            hasUnfinishedGame = false
            savedScore = 0
            return
        }
        hasUnfinishedGame = true
        savedScore = snapshot.score
    }
}
