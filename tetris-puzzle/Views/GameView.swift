import SwiftUI

struct GameView: View {
    @EnvironmentObject var scoreStore: ScoreStore
    @EnvironmentObject var savedGameStore: SavedGameStore
    @ObservedObject var game: GameState
    let onExit: () -> Void

    @State private var savedGameOver = false

    @State private var draggingPieceIndex: Int?
    @State private var dragLocation: CGPoint?
    @State private var pendingSnap: (row: Int, col: Int)?

    private let playfieldSpace = "playfield"
    private let horizontalPadding: CGFloat = 14
    private let topPadding: CGFloat = 6
    private let headerHeight: CGFloat = 56
    private let boardToTrayGap: CGFloat = 28
    private let bottomPadding: CGFloat = 24
    private let dragLift: CGFloat = 36

    var body: some View {
        GeometryReader { geo in
            let boardWidth = geo.size.width - horizontalPadding * 2
            let cellSize = boardWidth / CGFloat(GameState.boardSize)
            let boardSide = cellSize * CGFloat(GameState.boardSize)
            let trayCellSize = max(14, cellSize * 0.56)
            let slotWidth = boardWidth / 3
            let slotHeight = trayCellSize * 4

            let boardOrigin = CGPoint(
                x: (geo.size.width - boardSide) / 2,
                y: geo.size.height - bottomPadding - slotHeight - boardToTrayGap - boardSide
            )
            let boardRect = CGRect(x: boardOrigin.x, y: boardOrigin.y, width: boardSide, height: boardSide)

            let preview = computePreview(cellSize: cellSize, boardRect: boardRect)

            ZStack(alignment: .topLeading) {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, topPadding)

                    Spacer(minLength: 8)

                    BoardView(
                        game: game,
                        cellSize: cellSize,
                        previewShape: preview.shape,
                        previewOriginRow: preview.originRow,
                        previewOriginCol: preview.originCol,
                        previewIsValid: preview.isValid,
                        previewIsVisible: preview.isOverBoard,
                        clearPreviewCells: preview.clearCells
                    )
                    .frame(maxWidth: .infinity)

                    Color.clear.frame(height: boardToTrayGap)

                    PieceTrayView(
                        game: game,
                        trayCellSize: trayCellSize,
                        slotWidth: slotWidth,
                        slotHeight: slotHeight,
                        coordinateSpaceName: playfieldSpace,
                        draggingPieceIndex: draggingPieceIndex,
                        onDragChanged: { index, location in
                            handleDragChanged(
                                index: index,
                                location: location,
                                cellSize: cellSize,
                                boardRect: boardRect
                            )
                        }
                    )
                    .padding(.horizontal, horizontalPadding)

                    Color.clear.frame(height: bottomPadding)
                }

                if let idx = draggingPieceIndex,
                   let piece = game.trayPieces[idx],
                   let location = dragLocation {
                    floatingPiece(
                        piece: piece,
                        finger: location,
                        cellSize: cellSize,
                        isOverBoard: preview.isOverBoard
                    )
                }

                if game.isGameOver {
                    GameOverOverlay(
                        score: game.score,
                        onPlayAgain: {
                            savedGameOver = false
                            savedGameStore.clear()
                            game.newGame()
                        },
                        onHome: onExit
                    )
                    .environmentObject(scoreStore)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(2)
                }
            }
            .coordinateSpace(name: playfieldSpace)
            .simultaneousGesture(activeDragGesture(cellSize: cellSize, boardRect: boardRect))
            .overlay(alignment: .top) {
                if let announcement = game.comboAnnouncement {
                    ComboBannerView(announcement: announcement)
                        .padding(.top, topPadding + headerHeight + 6)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(3)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.82), value: game.comboAnnouncement)
        }
        .onChange(of: game.isGameOver) { _, newValue in
            if newValue, !savedGameOver {
                scoreStore.add(score: game.score)
                savedGameStore.clear()
                savedGameOver = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button(action: onExit) {
                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Home")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.accentDeep)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(Theme.surface)
                )
            }
            .accessibilityLabel("Home")

            Spacer()

            VStack(spacing: 2) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text("\(game.score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Best")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text("\(max(scoreStore.bestEverScore, game.score))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.accentDeep)
            }
            .frame(width: 60)
        }
        .frame(height: headerHeight)
        .overlay(alignment: .bottom) {
            if let msg = game.lastBonusMessage {
                Text(msg)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Theme.accent.opacity(0.12))
                    )
                    .offset(y: 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private struct PreviewState {
        var shape: PieceShape?
        var originRow: Int
        var originCol: Int
        var isValid: Bool
        var isOverBoard: Bool
        var clearCells: Set<Cell>

        static let hidden = PreviewState(
            shape: nil,
            originRow: 0,
            originCol: 0,
            isValid: false,
            isOverBoard: false,
            clearCells: []
        )
    }

    private func isPieceOverBoard(
        finger: CGPoint,
        piece: Piece,
        cellSize: CGFloat,
        boardRect: CGRect
    ) -> Bool {
        let topLeft = pieceTopLeft(finger: finger, piece: piece, cellSize: cellSize)
        let pieceRect = CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: CGFloat(piece.shape.width) * cellSize,
            height: CGFloat(piece.shape.height) * cellSize
        )
        return pieceRect.intersects(boardRect)
    }

    private func activeDragGesture(cellSize: CGFloat, boardRect: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(playfieldSpace))
            .onChanged { value in
                guard draggingPieceIndex != nil else { return }
                updateDragLocation(value.location, cellSize: cellSize, boardRect: boardRect)
            }
            .onEnded { value in
                guard let idx = draggingPieceIndex else { return }
                handleDragEnded(
                    pieceIndex: idx,
                    location: value.location,
                    cellSize: cellSize,
                    boardRect: boardRect
                )
            }
    }

    private func pieceTopLeft(finger: CGPoint, piece: Piece, cellSize: CGFloat) -> CGPoint {
        CGPoint(
            x: finger.x - CGFloat(piece.shape.width) * cellSize / 2,
            y: finger.y - CGFloat(piece.shape.height) * cellSize - dragLift
        )
    }

    private func snapRowCol(
        for piece: Piece,
        finger: CGPoint,
        cellSize: CGFloat,
        boardRect: CGRect
    ) -> (row: Int, col: Int) {
        let topLeft = pieceTopLeft(finger: finger, piece: piece, cellSize: cellSize)
        let localX = topLeft.x - boardRect.origin.x
        let localY = topLeft.y - boardRect.origin.y
        let col = Int(round(localX / cellSize))
        let row = Int(round(localY / cellSize))
        return (row, col)
    }

    private func updateDragLocation(_ location: CGPoint, cellSize: CGFloat, boardRect: CGRect) {
        dragLocation = location

        guard let idx = draggingPieceIndex, let piece = game.trayPieces[idx] else {
            pendingSnap = nil
            return
        }

        let snap = snapRowCol(for: piece, finger: location, cellSize: cellSize, boardRect: boardRect)
        if game.previewCells(piece.shape, atRow: snap.row, col: snap.col) != nil {
            pendingSnap = snap
        } else {
            pendingSnap = nil
        }
    }

    private func computePreview(cellSize: CGFloat, boardRect: CGRect) -> PreviewState {
        guard
            let idx = draggingPieceIndex,
            let piece = game.trayPieces[idx],
            let location = dragLocation
        else { return .hidden }

        guard isPieceOverBoard(
            finger: location,
            piece: piece,
            cellSize: cellSize,
            boardRect: boardRect
        ) else { return .hidden }

        let snap = snapRowCol(for: piece, finger: location, cellSize: cellSize, boardRect: boardRect)
        let isValid = game.previewCells(piece.shape, atRow: snap.row, col: snap.col) != nil
        let clearCells = isValid
            ? game.cellsClearedIfPlaced(piece.shape, atRow: snap.row, col: snap.col)
            : []

        return PreviewState(
            shape: piece.shape,
            originRow: snap.row,
            originCol: snap.col,
            isValid: isValid,
            isOverBoard: true,
            clearCells: clearCells
        )
    }

    private func floatingPiece(
        piece: Piece,
        finger: CGPoint,
        cellSize: CGFloat,
        isOverBoard: Bool
    ) -> some View {
        let topLeft = pieceTopLeft(finger: finger, piece: piece, cellSize: cellSize)

        return PieceShapeView(
            shape: piece.shape,
            color: piece.color,
            cellSize: cellSize,
            inset: 1,
            cornerRadius: 4
        )
        .opacity(isOverBoard ? 0.55 : 1)
        .offset(x: topLeft.x, y: topLeft.y)
        .allowsHitTesting(false)
        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 6)
        .zIndex(1)
    }

    private func handleDragChanged(
        index: Int,
        location: CGPoint,
        cellSize: CGFloat,
        boardRect: CGRect
    ) {
        draggingPieceIndex = index
        updateDragLocation(location, cellSize: cellSize, boardRect: boardRect)
    }

    private func handleDragEnded(
        pieceIndex: Int,
        location: CGPoint,
        cellSize: CGFloat,
        boardRect: CGRect
    ) {
        defer {
            draggingPieceIndex = nil
            dragLocation = nil
            pendingSnap = nil
        }

        guard let piece = game.trayPieces[pieceIndex] else { return }

        if let snap = pendingSnap, game.canPlace(piece.shape, atRow: snap.row, col: snap.col) {
            game.place(pieceIndex: pieceIndex, atRow: snap.row, col: snap.col)
            return
        }

        let snap = snapRowCol(for: piece, finger: location, cellSize: cellSize, boardRect: boardRect)
        if game.canPlace(piece.shape, atRow: snap.row, col: snap.col) {
            game.place(pieceIndex: pieceIndex, atRow: snap.row, col: snap.col)
        }
    }
}
