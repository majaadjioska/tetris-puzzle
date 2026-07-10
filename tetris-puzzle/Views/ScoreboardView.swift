import SwiftUI

struct ScoreboardView: View {
    let title: String
    let entries: [ScoreEntry]
    let formatter: DateFormatter
    var highlight: Color = Theme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            if entries.isEmpty {
                Text("No scores yet")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        row(index: index + 1, entry: entry)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(highlight.opacity(0.18), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private func row(index: Int, entry: ScoreEntry) -> some View {
        HStack(spacing: 10) {
            Text("\(index)")
                .font(.footnote.monospacedDigit().weight(.semibold))
                .foregroundStyle(highlight)
                .frame(width: 18, alignment: .leading)

            Text("\(entry.score)")
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text(formatter.string(from: entry.date))
                .font(.caption.monospacedDigit())
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

enum ScoreFormatters {
    static let dayTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    static let weekDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE HH:mm"
        return f
    }()

    static let allTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
