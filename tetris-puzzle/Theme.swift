import SwiftUI

enum Theme {
    // Backgrounds
    static let background = Color(red: 0.047, green: 0.086, blue: 0.067)
    static let boardBackground = Color(red: 0.078, green: 0.129, blue: 0.102)
    static let surface = Color(red: 0.114, green: 0.176, blue: 0.141)

    // Empty board cells (subtle checkerboard tone)
    static let cellEmpty = Color(red: 0.110, green: 0.161, blue: 0.129)
    static let cellEmptyAlt = Color(red: 0.086, green: 0.137, blue: 0.110)

    // Grid lines
    static let gridLine = Color(red: 0.278, green: 0.396, blue: 0.337)
    static let gridLineStrong = Color(red: 0.376, green: 0.522, blue: 0.443)

    // Accent / brand green
    static let accent = Color(red: 0.204, green: 0.725, blue: 0.553)
    static let accentDeep = Color(red: 0.157, green: 0.615, blue: 0.463)

    // Text
    static let textPrimary = Color(red: 0.945, green: 0.973, blue: 0.957)
    static let textSecondary = Color(red: 0.549, green: 0.647, blue: 0.600)

    static let danger = Color(red: 0.851, green: 0.427, blue: 0.380)

    // Pieces
    static let pieceFill = Color(red: 0.220, green: 0.733, blue: 0.561)
}
