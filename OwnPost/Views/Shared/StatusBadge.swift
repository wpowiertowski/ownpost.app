import SwiftUI

struct StatusBadge: View {
    let note: Note

    var body: some View {
        HStack(spacing: 4) {
            if note.isDraft {
                badge("Draft", color: .secondary)
            } else {
                badge("Published", color: .green)
            }

            if note.mastodonStatusID != nil {
                platformDot(color: .purple)
            }
            if note.blueskyURI != nil {
                platformDot(color: .blue)
            }
        }
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func platformDot(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
    }
}
