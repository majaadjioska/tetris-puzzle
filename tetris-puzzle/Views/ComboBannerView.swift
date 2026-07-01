import SwiftUI

struct ComboBannerView: View {
    let announcement: ComboAnnouncement

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: announcement.isHighlight ? "sparkles" : "bolt.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(announcement.isHighlight ? Theme.accent : Theme.accentDeep)

            VStack(alignment: .leading, spacing: 2) {
                Text(announcement.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)

                Text(announcement.subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: 8)

            Text("+\(announcement.bonusPoints)")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accentDeep)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: Theme.accent.opacity(0.22), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    announcement.isHighlight ? Theme.accent.opacity(0.45) : Theme.gridLine.opacity(0.5),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, 14)
    }
}
