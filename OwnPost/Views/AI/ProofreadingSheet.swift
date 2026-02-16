import SwiftUI

struct ProofreadingSheet: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @State private var suggestions: [ProofreadingService.Suggestion] = []
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Proofreading...")
                            .font(Constants.Design.monoCaption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(error)
                            .font(Constants.Design.monoCaption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if suggestions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(Constants.Design.accentColor)
                        Text("No suggestions — your writing looks good!")
                            .font(Constants.Design.monoCaption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(suggestions) { suggestion in
                            SuggestionRowView(
                                suggestion: suggestion,
                                onAccept: { acceptSuggestion(suggestion) }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Proofreading")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(Constants.Design.monoBody)
                }
            }
        }
        .task {
            await runProofreading()
        }
    }

    private func runProofreading() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let service = try ProofreadingService()
            suggestions = try await service.proofread(markdown: note.body)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func acceptSuggestion(_ suggestion: ProofreadingService.Suggestion) {
        note.body = note.body.replacingOccurrences(
            of: suggestion.originalText,
            with: suggestion.suggestedText
        )
        suggestions.removeAll { $0.id == suggestion.id }
    }
}

private struct SuggestionRowView: View {
    let suggestion: ProofreadingService.Suggestion
    let onAccept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(suggestion.explanation)
                .font(Constants.Design.monoSubheadline)

            HStack {
                VStack(alignment: .leading) {
                    Text("Original")
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(.secondary)
                    Text(suggestion.originalText)
                        .font(Constants.Design.monoBody)
                        .strikethrough()
                        .foregroundStyle(.red)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Suggested")
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(.secondary)
                    Text(suggestion.suggestedText)
                        .font(Constants.Design.monoBody)
                        .foregroundStyle(Constants.Design.accentColor)
                }
            }

            Button("Accept", action: onAccept)
                .font(Constants.Design.monoCaption)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}
