import SwiftUI

struct PublishSheet: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var options = PublishingCoordinator.PublishOptions()
    @State private var publishState: PublishingCoordinator.PublishState = .idle

    var body: some View {
        NavigationStack {
            Form {
                Section("Publish To") {
                    Toggle("Ghost Blog", isOn: $options.publishToGhost)
                }

                Section("Syndicate (POSSE)") {
                    Toggle("Mastodon", isOn: $options.syndicateToMastodon)
                    Toggle("Bluesky", isOn: $options.syndicateToBluesky)
                }

                if note.ghostPostID != nil {
                    Section {
                        Label("Previously published to Ghost", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section {
                    switch publishState {
                    case .idle:
                        Button("Publish Now") {
                            // Publishing is triggered via the coordinator
                            // This is a placeholder — coordinator injection is handled by the parent
                        }
                        .disabled(!options.publishToGhost && !options.syndicateToMastodon && !options.syndicateToBluesky)

                    case .publishingToGhost:
                        PublishProgressView(label: "Publishing to Ghost...")

                    case .syndicatingToMastodon:
                        PublishProgressView(label: "Syndicating to Mastodon...")

                    case .syndicatingToBluesky:
                        PublishProgressView(label: "Syndicating to Bluesky...")

                    case .completed(let results):
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Done!", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.headline)

                            ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                                HStack {
                                    Text(result.target.displayName)
                                    Spacer()
                                    Image(systemName: result.isSuccess ? "checkmark.circle" : "xmark.circle")
                                        .foregroundStyle(result.isSuccess ? .green : .red)
                                }
                            }
                        }

                    case .failed(let error):
                        Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Publish")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }
}
