import Foundation
import FoundationModels

/// Use @Generable for structured proofreading output via guided generation.
@Generable
struct ProofreadingSuggestion {
    @Guide(description: "The exact original text containing the issue")
    var original: String
    @Guide(description: "The corrected replacement text")
    var suggested: String
    @Guide(description: "Brief explanation of why this change is recommended")
    var explanation: String
}

@Generable
struct ProofreadingResult {
    @Guide(description: "Array of proofreading suggestions found in the text")
    var suggestions: [ProofreadingSuggestion]
}

actor ProofreadingService {
    private let session: LanguageModelSession

    struct Suggestion: Identifiable, Sendable {
        let id = UUID()
        let originalText: String
        let suggestedText: String
        let explanation: String
    }

    init() throws {
        guard SystemLanguageModel.default.isAvailable else {
            throw OnDeviceLLMService.AIError.modelUnavailable
        }
        self.session = LanguageModelSession(instructions: """
            You are a proofreader. Review markdown text for grammar, spelling, \
            awkward phrasing, and punctuation issues. Preserve all markdown formatting. \
            Only return genuine issues.
            """)
    }

    /// Proofread using guided generation with @Generable for reliable structured output
    @concurrent func proofread(markdown: String) async throws -> [Suggestion] {
        let response = try await session.respond(
            to: "Proofread the following markdown:\n\n\(markdown)",
            generating: ProofreadingResult.self
        )

        return response.content.suggestions.map { item in
            Suggestion(
                originalText: item.original,
                suggestedText: item.suggested,
                explanation: item.explanation
            )
        }
    }

    /// Stream proofreading results as they are generated
    func streamProofread(
        markdown: String
    ) -> LanguageModelSession.ResponseStream<ProofreadingResult> {
        session.streamResponse(
            to: "Proofread the following markdown:\n\n\(markdown)",
            generating: ProofreadingResult.self
        )
    }
}
