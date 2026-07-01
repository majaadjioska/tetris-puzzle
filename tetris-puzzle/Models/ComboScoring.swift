import SwiftUI

struct ComboAnnouncement: Equatable {
    let title: String
    let subtitle: String
    let bonusPoints: Int
    let isHighlight: Bool
}

enum ComboScoring {
    static let pointsPerClearUnit = 18

    /// Extra bonus for clearing multiple rows/columns/blocks in one move.
    static func simultaneousBonus(unitCount: Int) -> Int {
        switch unitCount {
        case 0, 1: return 0
        case 2: return 30
        case 3: return 75
        case 4: return 130
        case 5: return 200
        default: return 200 + (unitCount - 5) * 55
        }
    }

    /// Extra bonus for consecutive moves that each clear at least one line/block.
    /// Only the bonus for the current streak level — no re-scoring of earlier moves.
    static func sequentialBonus(streak: Int) -> Int {
        guard streak >= 2 else { return 0 }
        switch streak {
        case 2: return 25
        case 3: return 55
        case 4: return 95
        case 5: return 145
        default: return 145 + (streak - 5) * 50
        }
    }
}
