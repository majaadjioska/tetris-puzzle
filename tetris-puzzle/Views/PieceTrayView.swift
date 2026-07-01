import SwiftUI

struct PieceTrayView: View {
    @ObservedObject var game: GameState
    let trayCellSize: CGFloat
    let slotWidth: CGFloat
    let slotHeight: CGFloat
    let coordinateSpaceName: String
    let draggingPieceIndex: Int?
    let onDragChanged: (Int, CGPoint) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 3, id: \.self) { i in
                slot(index: i)
                    .frame(width: slotWidth, height: slotHeight)
            }
        }
    }

    @ViewBuilder
    private func slot(index i: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.boardBackground.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.gridLine.opacity(0.4), lineWidth: 1)
                )

            if let piece = game.trayPieces[i] {
                PieceShapeView(
                    shape: piece.shape,
                    color: piece.color,
                    cellSize: trayCellSize
                )
                .opacity(draggingPieceIndex == i ? 0.25 : 1)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpaceName))
                .onChanged { value in
                    guard game.trayPieces[i] != nil else { return }
                    onDragChanged(i, value.location)
                }
        )
    }
}
