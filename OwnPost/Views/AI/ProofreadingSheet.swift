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
                        Text("Proofreading with on-device AI...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if suggestions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                        Text("No suggestions — your writing looks good!")
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
                }
            }
        }
        .task {
            await runProofreading()
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 400)
        #endif
    }

    private func runProofreading() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let llm = OnDeviceLLMService()
            try await llm.initialize()
            let service = ProofreadingService(llm: llm)
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
