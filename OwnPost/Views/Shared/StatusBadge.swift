import SwiftUI

struct StatusBadge: View {
    let note: Note

    var body: some View {
        HStack(spacing: 6) {
            if !note.isDraft {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(Constants.Design.accentColor)
            }

            if note.mastodonStatusID != nil {
                Circle()
                    .fill(.purple)
                    .frame(width: 5, height: 5)
            }

            if note.blueskyURI != nil {
                Circle()
                    .fill(.blue)
                    .frame(width: 5, height: 5)
            }
        }
    }
}
