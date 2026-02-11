import Foundation
import FoundationModels

/// Thin wrapper around the system Foundation Models framework.
/// With iOS 26+ as minimum target, the model is always present on supported hardware.
actor OnDeviceLLMService {
    private let session: LanguageModelSession

    enum AIError: Error, LocalizedError {
        case modelUnavailable

        var errorDescription: String? {
            switch self {
            case .modelUnavailable:
                "On-device AI model is not available — ensure Apple Intelligence is enabled"
            }
        }
    }

    init(instructions: String = "") throws {
        guard SystemLanguageModel.default.isAvailable else {
            throw AIError.modelUnavailable
        }
        self.session = if instructions.isEmpty {
            LanguageModelSession()
        } else {
            LanguageModelSession(instructions: instructions)
        }
    }

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    /// Generate a plain text response
    @concurrent func generate(prompt: String) async throws -> String {
        let response = try await session.respond(to: prompt)
        return response.content
    }

    /// Generate a structured response using @Generable types (guided generation)
    @concurrent func generate<T: Generable>(
        prompt: String,
        generating type: T.Type
    ) async throws -> T {
        try await session.respond(to: prompt, generating: type)
    }

    /// Stream a structured response, yielding partial snapshots
    @concurrent func stream<T: Generable>(
        prompt: String,
        generating type: T.Type
    ) -> some AsyncSequence<T.PartiallyGenerated, any Error> {
        session.streamResponse(to: prompt, generating: type)
    }
}
