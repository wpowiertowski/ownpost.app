import SwiftUI

struct PublishHistoryView: View {
    let note: Note

    var body: some View {
        List {
            if note.publishRecords.isEmpty {
                Text("No publish history")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(note.publishRecords.sorted(by: { $0.publishedAt > $1.publishedAt })) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(record.platform.capitalized)
                                .font(.headline)
                            Spacer()
                            Text(record.publishedAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let url = record.externalURL {
                            Link(url, destination: URL(string: url)!)
                                .font(.caption)
                        }

                        Text("ID: \(record.externalID)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Publish History")
    }
}
