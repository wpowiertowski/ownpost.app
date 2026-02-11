import SwiftUI

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text(lastUpdatedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                StatusBadge(note: note)
            }

            if !note.body.isEmpty {
                Text(note.body.prefix(100))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private var lastUpdatedText: String {
        let seconds = max(0, Date().timeIntervalSince(note.modifiedAt))

        if seconds < 3600 {
            let minutes = max(1, Int(seconds / 60))
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        }

        if seconds < 86_400 {
            let hours = Int(seconds / 3600)
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        }

        if seconds < 604_800 {
            let days = Int(seconds / 86_400)
            return days == 1 ? "1 day ago" : "\(days) days ago"
        }

        if seconds < 2_419_200 {
            let weeks = Int(seconds / 604_800)
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        }

        return note.modifiedAt.formatted(date: .abbreviated, time: .omitted)
    }
}
