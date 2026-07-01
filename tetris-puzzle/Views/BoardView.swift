import SwiftUI

struct BoardView: View {
    @ObservedObject var game: GameState
    let cellSize: CGFloat
    let previewShape: PieceShape?
    let previewOriginRow: Int
    let previewOriginCol: Int
    let previewIsValid: Bool
    let previewIsVisible: Bool

    private var boardSide: CGFloat {
        cellSize * CGFloat(GameState.boardSize)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.boardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

            cellsGrid

            if previewIsVisible, let previewShape {
                piecePreviewOverlay(shape: previewShape)
                    .transition(.opacity)
            }

            gridLines
                .allowsHitTesting(false)
        }
        .frame(width: boardSide, height: boardSide)
        .animation(.easeOut(duration: 0.08), value: previewOriginRow)
        .animation(.easeOut(duration: 0.08), value: previewOriginCol)
        .animation(.easeOut(duration: 0.08), value: previewIsValid)
    }

    private func piecePreviewOverlay(shape: PieceShape) -> some View {
        let previewColor = previewIsValid ? Theme.pieceFill : Theme.danger
        let strokeColor = previewIsValid ? Theme.accentDeep : Theme.danger

        return ZStack(alignment: .topLeading) {
            PieceShapeView(
                shape: shape,
                color: previewColor,
                cellSize: cellSize,
                inset: 1,
                cornerRadius: 4
            )
            .opacity(previewIsValid ? 0.38 : 0.30)

            ForEach(shape.cells, id: \.self) { cell in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(strokeColor, lineWidth: 2)
                    .frame(width: cellSize - 2, height: cellSize - 2)
                    .offset(
                        x: CGFloat(cell.col) * cellSize + 1,
                        y: CGFloat(cell.row) * cellSize + 1
                    )
            }
        }
        .offset(
            x: CGFloat(previewOriginCol) * cellSize,
            y: CGFloat(previewOriginRow) * cellSize
        )
        .allowsHitTesting(false)
    }

    private var cellsGrid: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< GameState.boardSize, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0 ..< GameState.boardSize, id: \.self) { c in
                        cellView(row: r, col: c)
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(row r: Int, col c: Int) -> some View {
        let boardCell = game.board[r][c]

        ZStack {
            let blockTone = ((r / GameState.blockSize) + (c / GameState.blockSize)) % 2
            (blockTone == 0 ? Theme.cellEmpty : Theme.cellEmptyAlt)

            if boardCell.filled, boardCell.colorIndex != nil {
                filledOverlay(color: Theme.pieceFill)
                    .opacity(boardCell.clearing ? 0.0 : 1.0)
                    .scaleEffect(boardCell.clearing ? 0.3 : 1.0)
                    .animation(.easeIn(duration: 0.22), value: boardCell.clearing)
            }
        }
        .overlay(
            Rectangle()
                .stroke(Theme.gridLine.opacity(0.45), lineWidth: 0.5)
        )
    }

    private func filledOverlay(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .inset(by: 2)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .padding(1)
    }

    private var gridLines: some View {
        Canvas { context, _ in
            let total = boardSide
            for i in 1 ..< GameState.boardSize {
                let isMajor = i % GameState.blockSize == 0
                let lineWidth: CGFloat = isMajor ? 3.0 : 1.0
                let color = isMajor ? Theme.gridLineStrong.opacity(0.80) : Theme.gridLine.opacity(0.70)

                let x = CGFloat(i) * cellSize
                var vertical = Path()
                vertical.move(to: CGPoint(x: x, y: 0))
                vertical.addLine(to: CGPoint(x: x, y: total))
                context.stroke(vertical, with: .color(color), lineWidth: lineWidth)

                let y = CGFloat(i) * cellSize
                var horizontal = Path()
                horizontal.move(to: CGPoint(x: 0, y: y))
                horizontal.addLine(to: CGPoint(x: total, y: y))
                context.stroke(horizontal, with: .color(color), lineWidth: lineWidth)
            }
        }
    }
}
