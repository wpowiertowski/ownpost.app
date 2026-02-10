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
                    ContentUnavailableView {
                        ProgressView()
                    } description: {
                        Text("Proofreading with on-device AI...")
                    }
                } else if let error {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    }
                } else if suggestions.isEmpty {
                    ContentUnavailableView {
                        Label("All Clear", systemImage: "checkmark.circle")
                    } description: {
                        Text("No suggestions — your writing looks good!")
                    }
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
                .font(.subheadline)

            HStack {
                VStack(alignment: .leading) {
                    Text("Original")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(suggestion.originalText)
                        .strikethrough()
                        .foregroundStyle(.red)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Suggested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(suggestion.suggestedText)
                        .foregroundStyle(.green)
                }
            }

            Button("Accept", action: onAccept)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}
