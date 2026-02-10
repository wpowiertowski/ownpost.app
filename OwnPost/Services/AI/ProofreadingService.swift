import Foundation

actor ProofreadingService {
    private let llm: OnDeviceLLMService

    init(llm: OnDeviceLLMService) {
        self.llm = llm
    }

    struct Suggestion: Identifiable, Sendable {
        let id: UUID
        let originalText: String
        let suggestedText: String
        let explanation: String
    }

    func proofread(markdown: String) async throws -> [Suggestion] {
        let prompt = """
        You are a proofreader. Review the following markdown text for:
        - Grammar and spelling errors
        - Awkward phrasing
        - Punctuation issues

        Return each suggestion as a JSON array of objects with keys: "original", "suggested", "explanation"
        Only return issues found. Preserve all markdown formatting.
        If no issues are found, return an empty array: []

        Text:
        \(markdown)
        """

        let response = try await llm.generate(prompt: prompt)
        return parseSuggestions(response)
    }

    private func parseSuggestions(_ response: String) -> [Suggestion] {
        // Extract JSON array from response
        guard let jsonData = response.data(using: .utf8) else { return [] }

        struct RawSuggestion: Decodable {
            let original: String
            let suggested: String
            let explanation: String
        }

        guard let raw = try? JSONDecoder().decode([RawSuggestion].self, from: jsonData) else {
            return []
        }

        return raw.map { item in
            Suggestion(
                id: UUID(),
                originalText: item.original,
                suggestedText: item.suggested,
                explanation: item.explanation
            )
        }
    }
}
