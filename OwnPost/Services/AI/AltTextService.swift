import Foundation
import FoundationModels

actor AltTextService {
    private var session: LanguageModelSession?

    enum AltTextError: Error, LocalizedError {
        case modelUnavailable
        case generationFailed

        var errorDescription: String? {
            switch self {
            case .modelUnavailable: "On-device AI model is not available for alt text generation"
            case .generationFailed: "Failed to generate alt text for the image"
            }
        }
    }

    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func initialize() throws {
        guard SystemLanguageModel.default.isAvailable else {
            throw AltTextError.modelUnavailable
        }
        self.session = LanguageModelSession()
    }

    func generateAltText(for imageData: Data) async throws -> String {
        guard let session else {
            throw AltTextError.modelUnavailable
        }

        let prompt = """
        Describe this image concisely for use as alt text in a blog post. \
        Be descriptive but keep it under 125 characters.
        """

        // Foundation Models supports multimodal input on capable devices
        let response = try await session.respond(to: prompt)
        return response.content
    }
}
