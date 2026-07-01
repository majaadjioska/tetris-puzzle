import SwiftUI

struct Cell: Hashable, Codable {
    let row: Int
    let col: Int
}

struct PieceShape: Hashable, Codable {
    let cells: [Cell]
    let width: Int
    let height: Int

    init(cells: [Cell], width: Int, height: Int) {
        self.cells = cells
        self.width = width
        self.height = height
    }

    init(_ rawCells: [(Int, Int)]) {
        let cells = rawCells.map { Cell(row: $0.0, col: $0.1) }
        let minRow = cells.map(\.row).min() ?? 0
        let minCol = cells.map(\.col).min() ?? 0
        let normalized = cells.map { Cell(row: $0.row - minRow, col: $0.col - minCol) }
        self.cells = normalized
        self.height = (normalized.map(\.row).max() ?? 0) + 1
        self.width = (normalized.map(\.col).max() ?? 0) + 1
    }

    var cellCount: Int { cells.count }
}

enum PieceLibrary {
    static let shapes: [PieceShape] = [
        // 1x1 single
        PieceShape([(0, 0)]),

        // Horizontal lines (2-5)
        PieceShape([(0, 0), (0, 1)]),
        PieceShape([(0, 0), (0, 1), (0, 2)]),
        PieceShape([(0, 0), (0, 1), (0, 2), (0, 3)]),
        PieceShape([(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)]),

        // Vertical lines (2-5)
        PieceShape([(0, 0), (1, 0)]),
        PieceShape([(0, 0), (1, 0), (2, 0)]),
        PieceShape([(0, 0), (1, 0), (2, 0), (3, 0)]),
        PieceShape([(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]),

        // 2x2 square
        PieceShape([(0, 0), (0, 1), (1, 0), (1, 1)]),

        // Small L (4 rotations)
        PieceShape([(0, 0), (1, 0), (1, 1)]),
        PieceShape([(0, 0), (0, 1), (1, 1)]),
        PieceShape([(0, 1), (1, 0), (1, 1)]),
        PieceShape([(0, 0), (0, 1), (1, 0)]),

        // Big L (4 rotations, 3x3 bounding box)
        PieceShape([(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)]),
        PieceShape([(0, 0), (0, 1), (0, 2), (1, 0), (2, 0)]),
        PieceShape([(0, 0), (0, 1), (0, 2), (1, 2), (2, 2)]),
        PieceShape([(0, 2), (1, 2), (2, 0), (2, 1), (2, 2)]),

        // T shapes (4 rotations)
        PieceShape([(0, 0), (0, 1), (0, 2), (1, 1)]),
        PieceShape([(0, 1), (1, 0), (1, 1), (1, 2)]),
        PieceShape([(0, 0), (1, 0), (1, 1), (2, 0)]),
        PieceShape([(0, 1), (1, 0), (1, 1), (2, 1)]),

        // S / Z (horizontal & vertical)
        PieceShape([(0, 1), (0, 2), (1, 0), (1, 1)]),
        PieceShape([(0, 0), (0, 1), (1, 1), (1, 2)]),
        PieceShape([(0, 0), (1, 0), (1, 1), (2, 1)]),
        PieceShape([(0, 1), (1, 0), (1, 1), (2, 0)]),

        // Plus
        PieceShape([(0, 1), (1, 0), (1, 1), (1, 2), (2, 1)]),

        // Diagonals
        PieceShape([(0, 0), (1, 1)]),
        PieceShape([(0, 1), (1, 0)]),
        PieceShape([(0, 0), (1, 1), (2, 2)]),
        PieceShape([(0, 2), (1, 1), (2, 0)]),

        // I 4-tall corner pieces (L tetromino-style, 2x3)
        PieceShape([(0, 0), (1, 0), (1, 1)]),
        PieceShape([(0, 0), (0, 1), (1, 0), (2, 0)]),
        PieceShape([(0, 0), (0, 1), (1, 1), (2, 1)]),
    ]

    static func random() -> PieceShape {
        shapes.randomElement()!
    }
}

struct Piece: Identifiable, Hashable, Codable {
    let id: UUID
    let shape: PieceShape
    let colorIndex: Int

    var color: Color { Theme.pieceFill }

    init(id: UUID = UUID(), shape: PieceShape, colorIndex: Int) {
        self.id = id
        self.shape = shape
        self.colorIndex = colorIndex
    }

    static func random() -> Piece {
        Piece(shape: PieceLibrary.random(), colorIndex: 0)
    }
}
