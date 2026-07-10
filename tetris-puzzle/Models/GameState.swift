import SwiftUI

struct BoardCell: Hashable, Codable {
    var filled: Bool
    var colorIndex: Int?
    var clearing: Bool

    static let empty = BoardCell(filled: false, colorIndex: nil, clearing: false)

    static func filled(colorIndex: Int) -> BoardCell {
        BoardCell(filled: true, colorIndex: colorIndex, clearing: false)
    }
}

final class GameState: ObservableObject {
    static let boardSize = 9
    static let blockSize = 3

    @Published private(set) var board: [[BoardCell]]
    @Published private(set) var trayPieces: [Piece?]
    @Published private(set) var score: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published var lastBonusMessage: String?
    @Published var comboAnnouncement: ComboAnnouncement?

    private var consecutiveClearStreak = 0
    private var comboAnnouncementToken = UUID()

    init() {
        board = Self.emptyBoard()
        trayPieces = (0 ..< 3).map { _ in Piece.random() }
    }

    private static func emptyBoard() -> [[BoardCell]] {
        Array(
            repeating: Array(repeating: BoardCell.empty, count: boardSize),
            count: boardSize
        )
    }

    func newGame() {
        withAnimation(.easeInOut(duration: 0.2)) {
            board = Self.emptyBoard()
            trayPieces = (0 ..< 3).map { _ in Piece.random() }
            score = 0
            isGameOver = false
            lastBonusMessage = nil
            comboAnnouncement = nil
            consecutiveClearStreak = 0
        }
    }

    func snapshot() -> SavedGameSnapshot {
        SavedGameSnapshot(
            board: board.map { row in
                row.map { cell in
                    BoardCell(filled: cell.filled, colorIndex: cell.colorIndex, clearing: false)
                }
            },
            trayPieces: trayPieces,
            score: score,
            consecutiveClearStreak: consecutiveClearStreak
        )
    }

    func restore(from snapshot: SavedGameSnapshot) {
        board = snapshot.board
        trayPieces = snapshot.trayPieces
        score = snapshot.score
        consecutiveClearStreak = snapshot.consecutiveClearStreak
        isGameOver = false
        lastBonusMessage = nil
        comboAnnouncement = nil
    }

    func canPlace(_ shape: PieceShape, atRow row: Int, col: Int) -> Bool {
        for cell in shape.cells {
            let r = row + cell.row
            let c = col + cell.col
            if r < 0 || r >= Self.boardSize { return false }
            if c < 0 || c >= Self.boardSize { return false }
            if board[r][c].filled { return false }
        }
        return true
    }

    /// Cells that would be cleared (full rows, columns, and 3×3 blocks) if this
    /// shape were placed at the given origin. Empty if the placement is invalid
    /// or completes nothing. Used to preview clears while dragging.
    func cellsClearedIfPlaced(_ shape: PieceShape, atRow row: Int, col: Int) -> Set<Cell> {
        guard canPlace(shape, atRow: row, col: col) else { return [] }

        var filled = board.map { $0.map(\.filled) }
        for cell in shape.cells {
            filled[row + cell.row][col + cell.col] = true
        }

        var cleared = Set<Cell>()

        for r in 0 ..< Self.boardSize where (0 ..< Self.boardSize).allSatisfy({ filled[r][$0] }) {
            for c in 0 ..< Self.boardSize { cleared.insert(Cell(row: r, col: c)) }
        }

        for c in 0 ..< Self.boardSize where (0 ..< Self.boardSize).allSatisfy({ filled[$0][c] }) {
            for r in 0 ..< Self.boardSize { cleared.insert(Cell(row: r, col: c)) }
        }

        let blocks = Self.boardSize / Self.blockSize
        for br in 0 ..< blocks {
            for bc in 0 ..< blocks {
                let allFilled = (0 ..< Self.blockSize).allSatisfy { dr in
                    (0 ..< Self.blockSize).allSatisfy { dc in
                        filled[br * Self.blockSize + dr][bc * Self.blockSize + dc]
                    }
                }
                if allFilled {
                    for dr in 0 ..< Self.blockSize {
                        for dc in 0 ..< Self.blockSize {
                            cleared.insert(Cell(
                                row: br * Self.blockSize + dr,
                                col: bc * Self.blockSize + dc
                            ))
                        }
                    }
                }
            }
        }

        return cleared
    }

    func previewCells(_ shape: PieceShape, atRow row: Int, col: Int) -> Set<Cell>? {
        var result = Set<Cell>()
        for cell in shape.cells {
            let r = row + cell.row
            let c = col + cell.col
            if r < 0 || r >= Self.boardSize { return nil }
            if c < 0 || c >= Self.boardSize { return nil }
            if board[r][c].filled { return nil }
            result.insert(Cell(row: r, col: c))
        }
        return result
    }

    @discardableResult
    func place(pieceIndex: Int, atRow row: Int, col: Int) -> Bool {
        guard pieceIndex >= 0, pieceIndex < trayPieces.count else { return false }
        guard let piece = trayPieces[pieceIndex] else { return false }
        guard canPlace(piece.shape, atRow: row, col: col) else { return false }

        withAnimation(.easeOut(duration: 0.12)) {
            for cell in piece.shape.cells {
                let r = row + cell.row
                let c = col + cell.col
                board[r][c] = .filled(colorIndex: piece.colorIndex)
            }
            score += piece.shape.cellCount
            trayPieces[pieceIndex] = nil
            lastBonusMessage = nil
            comboAnnouncement = nil
        }

        let result = findClears()
        if !result.cells.isEmpty {
            withAnimation(.easeInOut(duration: 0.18)) {
                for cell in result.cells {
                    board[cell.row][cell.col].clearing = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [weak self] in
                guard let self else { return }
                self.commitClears(result)
            }
        } else {
            consecutiveClearStreak = 0
            finalizeMove()
        }
        return true
    }

    private func commitClears(_ result: ClearResult) {
        consecutiveClearStreak += 1

        let baseClearPoints = result.unitCount * ComboScoring.pointsPerClearUnit
        let simultaneousBonus = ComboScoring.simultaneousBonus(unitCount: result.unitCount)
        let sequentialBonus = ComboScoring.sequentialBonus(streak: consecutiveClearStreak)
        let comboBonusTotal = simultaneousBonus + sequentialBonus
        let clearPoints = baseClearPoints + comboBonusTotal

        withAnimation(.easeIn(duration: 0.22)) {
            for cell in result.cells {
                board[cell.row][cell.col] = .empty
            }
            score += clearPoints
            lastBonusMessage = makeBonusMessage(
                unitCount: result.unitCount,
                streak: consecutiveClearStreak,
                clearPoints: clearPoints,
                comboBonus: comboBonusTotal
            )
            showComboAnnouncement(
                unitCount: result.unitCount,
                streak: consecutiveClearStreak,
                simultaneousBonus: simultaneousBonus,
                sequentialBonus: sequentialBonus,
                comboBonusTotal: comboBonusTotal
            )
        }
        finalizeMove()
    }

    private func makeBonusMessage(
        unitCount: Int,
        streak: Int,
        clearPoints: Int,
        comboBonus: Int
    ) -> String {
        if comboBonus > 0 {
            return "+\(clearPoints)  (+\(comboBonus) combo)"
        }
        return "Clear!  +\(clearPoints)"
    }

    private func showComboAnnouncement(
        unitCount: Int,
        streak: Int,
        simultaneousBonus: Int,
        sequentialBonus: Int,
        comboBonusTotal: Int
    ) {
        let hasSimultaneous = unitCount >= 2
        let hasSequential = streak >= 2
        guard hasSimultaneous || hasSequential else {
            comboAnnouncement = nil
            return
        }

        let title: String
        let subtitle: String
        let isHighlight: Bool

        if hasSimultaneous && hasSequential {
            title = "Mega combo!"
            subtitle = "\(unitCount) clears at once · streak ×\(streak)"
            isHighlight = true
        } else if hasSimultaneous {
            title = unitCount >= 3 ? "Combo ×\(unitCount)!" : "Double clear!"
            subtitle = "\(unitCount) rows, columns, or blocks"
            isHighlight = unitCount >= 3
        } else {
            title = "Streak ×\(streak)!"
            subtitle = "\(streak) clearing moves in a row"
            isHighlight = streak >= 3
        }

        let announcement = ComboAnnouncement(
            title: title,
            subtitle: subtitle,
            bonusPoints: comboBonusTotal,
            isHighlight: isHighlight
        )
        let token = UUID()
        comboAnnouncementToken = token
        comboAnnouncement = announcement

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            guard let self, self.comboAnnouncementToken == token else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                self.comboAnnouncement = nil
            }
        }
    }

    private func finalizeMove() {
        if trayPieces.allSatisfy({ $0 == nil }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                trayPieces = (0 ..< 3).map { _ in Piece.random() }
            }
        }
        if !anyRemainingPieceFits() {
            withAnimation(.easeInOut(duration: 0.25)) {
                isGameOver = true
            }
        }
    }

    private struct ClearResult {
        var cells: Set<Cell>
        var unitCount: Int
    }

    private func findClears() -> ClearResult {
        var cells = Set<Cell>()
        var unitCount = 0

        for r in 0 ..< Self.boardSize {
            if (0 ..< Self.boardSize).allSatisfy({ board[r][$0].filled }) {
                unitCount += 1
                for c in 0 ..< Self.boardSize {
                    cells.insert(Cell(row: r, col: c))
                }
            }
        }

        for c in 0 ..< Self.boardSize {
            if (0 ..< Self.boardSize).allSatisfy({ board[$0][c].filled }) {
                unitCount += 1
                for r in 0 ..< Self.boardSize {
                    cells.insert(Cell(row: r, col: c))
                }
            }
        }

        let blocks = Self.boardSize / Self.blockSize
        for br in 0 ..< blocks {
            for bc in 0 ..< blocks {
                let allFilled = (0 ..< Self.blockSize).allSatisfy { dr in
                    (0 ..< Self.blockSize).allSatisfy { dc in
                        board[br * Self.blockSize + dr][bc * Self.blockSize + dc].filled
                    }
                }
                if allFilled {
                    unitCount += 1
                    for dr in 0 ..< Self.blockSize {
                        for dc in 0 ..< Self.blockSize {
                            cells.insert(Cell(
                                row: br * Self.blockSize + dr,
                                col: bc * Self.blockSize + dc
                            ))
                        }
                    }
                }
            }
        }

        return ClearResult(cells: cells, unitCount: unitCount)
    }

    private func anyRemainingPieceFits() -> Bool {
        let remaining = trayPieces.compactMap { $0 }
        guard !remaining.isEmpty else { return true }
        for piece in remaining {
            if pieceFitsSomewhere(piece.shape) { return true }
        }
        return false
    }

    private func pieceFitsSomewhere(_ shape: PieceShape) -> Bool {
        let maxRow = Self.boardSize - shape.height
        let maxCol = Self.boardSize - shape.width
        guard maxRow >= 0, maxCol >= 0 else { return false }
        for r in 0 ... maxRow {
            for c in 0 ... maxCol {
                if canPlace(shape, atRow: r, col: c) { return true }
            }
        }
        return false
    }
}
