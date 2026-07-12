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
                let fits = game.trayPieceFits(at: i)
                PieceShapeView(
                    shape: piece.shape,
                    color: fits ? piece.color : Theme.gridLine,
                    cellSize: trayCellSize
                )
                .saturation(fits ? 1 : 0)
                .opacity(draggingPieceIndex == i ? 0.25 : (fits ? 1 : 0.35))
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpaceName))
                .onChanged { value in
                    guard game.trayPieces[i] != nil,
                          game.trayPieceFits(at: i) else { return }
                    onDragChanged(i, value.location)
                }
        )
    }
}
