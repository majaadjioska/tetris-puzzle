import SwiftUI

struct PieceShapeView: View {
    let shape: PieceShape
    let color: Color
    let cellSize: CGFloat
    var inset: CGFloat = 2
    var cornerRadius: CGFloat = 5

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(shape.cells, id: \.self) { cell in
                pieceCell
                    .frame(
                        width: cellSize - inset * 2,
                        height: cellSize - inset * 2
                    )
                    .offset(
                        x: CGFloat(cell.col) * cellSize + inset,
                        y: CGFloat(cell.row) * cellSize + inset
                    )
            }
        }
        .frame(
            width: CGFloat(shape.width) * cellSize,
            height: CGFloat(shape.height) * cellSize,
            alignment: .topLeading
        )
    }

    private var pieceCell: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .inset(by: 2)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}
