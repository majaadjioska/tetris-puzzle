# Jadeku

A calm 9×9 block puzzle iOS game built with SwiftUI, published by voidfang. Drag Woodoku-style pieces onto the board, clear full rows, columns, or 3×3 blocks, and play as long as you can fit pieces.

## Features

- 9×9 board divided into nine 3×3 blocks (sudoku-style)
- A tray of 3 pieces at a time; a new set of 3 is generated once you've placed all current pieces
- Pieces are drag-and-drop with a live placement preview (valid placements are highlighted in green, invalid in red)
- Clears trigger when any of the following are full:
  - A row of 9
  - A column of 9
  - A 3×3 block
  - Any combination at once (combo bonus)
- No timer — pure puzzle, no pressure
- Calm emerald/sage color palette
- Score, today's top 5, this week's top 5, and all-time top 5 — persisted on the device
- Game over when no remaining piece can fit anywhere

## Scoring

- +1 point per cell placed
- +18 points per cleared unit (row, column, or 3×3 block)
- +10 bonus per additional unit cleared in the same move (combos)

## Requirements

- Xcode 16 or newer
- iOS 17 deployment target (iPhone & iPad supported)

## Running

1. Open `tetris-puzzle.xcodeproj` in Xcode
2. Pick a simulator (iPhone 15 / 16 recommended) or your device
3. Hit ⌘R

## Project structure

```
tetris-puzzle/
├── tetris_puzzleApp.swift   # App entry point
├── RootView.swift           # Top-level router (home ↔ game)
├── Theme.swift              # Color palette
├── Models/
│   ├── PieceShape.swift     # All ~30 Woodoku piece shapes + Piece type
│   ├── GameState.swift      # Board state, placement, clears, game-over
│   └── ScoreStore.swift     # Persisted scores (UserDefaults)
└── Views/
    ├── HomeView.swift       # Title + scoreboards + Play button
    ├── GameView.swift       # The main game (drag/drop, layout)
    ├── GameOverView.swift   # End-of-game overlay
    ├── BoardView.swift      # 9×9 grid + placement preview
    ├── PieceTrayView.swift  # Three piece slots below the board
    ├── PieceShapeView.swift # Renders a single piece
    └── ScoreboardView.swift # Reusable top-5 list
```

## Notes

- Scores are stored in `UserDefaults` under the key `jadeku.scores.v1`. Delete the app or call `ScoreStore.clearAll()` to reset.
- The bundle identifier is `com.voidfang.jadeku`.
- Game Center leaderboard IDs: `jadeku_alltime` (classic), `jadeku_weekly` and `jadeku_daily` (recurring).
