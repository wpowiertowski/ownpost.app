import SwiftUI

struct NoteRowView: View {
    let note: Note
    var sortOrder: NoteSortOrder = .created

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(Constants.Design.monoHeadline)
                    .lineLimit(1)

                StatusBadge(note: note)

                Spacer()

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 0) {
                Text(displayDate.formatted(.relative(presentation: .named)))
                    .font(Constants.Design.monoCaption)
                    .foregroundStyle(.tertiary)

                if !note.body.isEmpty {
                    Text(" · ")
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(.tertiary)

                    Text(note.body.prefix(60))
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var displayDate: Date {
        switch sortOrder {
        case .modified:
            return note.modifiedAt
        case .created:
            return note.createdAt
        case .published:
            return note.publishedAt ?? note.createdAt
        }
    }
}
