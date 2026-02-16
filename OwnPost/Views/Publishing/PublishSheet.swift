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
                Section {
                    Toggle("Ghost Blog", isOn: $options.publishToGhost)
                        .font(Constants.Design.monoBody)
                } header: {
                    Text("Publish To")
                        .font(Constants.Design.monoCaption)
                }

                Section {
                    Toggle("Mastodon", isOn: $options.syndicateToMastodon)
                        .font(Constants.Design.monoBody)
                    Toggle("Bluesky", isOn: $options.syndicateToBluesky)
                        .font(Constants.Design.monoBody)
                } header: {
                    Text("Syndicate (POSSE)")
                        .font(Constants.Design.monoCaption)
                }

                if note.ghostPostID != nil {
                    Section {
                        Label("Previously published to Ghost", systemImage: "checkmark.circle.fill")
                            .font(Constants.Design.monoCaption)
                            .foregroundStyle(Constants.Design.accentColor)
                    }
                }

                Section {
                    switch publishState {
                    case .idle:
                        Button("Publish Now") {
                            // Publishing is triggered via the coordinator
                            // This is a placeholder — coordinator injection is handled by the parent
                        }
                        .font(Constants.Design.monoBody)
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
                                .foregroundStyle(Constants.Design.accentColor)
                                .font(Constants.Design.monoHeadline)

                            ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                                HStack {
                                    Text(result.target.displayName)
                                        .font(Constants.Design.monoBody)
                                    Spacer()
                                    Image(systemName: result.isSuccess ? "checkmark.circle" : "xmark.circle")
                                        .foregroundStyle(result.isSuccess ? Constants.Design.accentColor : .red)
                                }
                            }
                        }

                    case .failed(let error):
                        Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                            .font(Constants.Design.monoCaption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Publish")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(Constants.Design.monoBody)
                }
            }
        }
    }
}
