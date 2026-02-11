import Foundation
import FoundationModels

/// Structured alt text output via guided generation.
@Generable
struct AltTextResult {
    @Guide(description: "Concise image description for alt text, under 125 characters")
    var altText: String
}

actor AltTextService {
    private let session: LanguageModelSession

    init() throws {
        guard SystemLanguageModel.default.isAvailable else {
            throw OnDeviceLLMService.AIError.modelUnavailable
        }
        self.session = LanguageModelSession(instructions: """
            You generate concise, descriptive alt text for images used in blog posts. \
            Keep descriptions under 125 characters. Focus on what the image depicts, \
            not how it looks stylistically.
            """)
    }

    @concurrent func generateAltText(for context: String) async throws -> String {
        let response = try await session.respond(
            to: "Generate alt text for an image described as: \(context)",
            generating: AltTextResult.self
        )
        return response.content.altText
    }
}
