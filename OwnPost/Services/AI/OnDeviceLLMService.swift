import Foundation
import FoundationModels

actor OnDeviceLLMService {
    private var session: LanguageModelSession?

    enum AIError: Error, LocalizedError {
        case modelUnavailable
        case generationFailed(String)

        var errorDescription: String? {
            switch self {
            case .modelUnavailable:
                "On-device AI model is not available on this device"
            case .generationFailed(let reason):
                "AI generation failed: \(reason)"
            }
        }
    }

    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func initialize() throws {
        guard SystemLanguageModel.default.isAvailable else {
            throw AIError.modelUnavailable
        }
        self.session = LanguageModelSession()
    }

    func generate(prompt: String) async throws -> String {
        guard let session else {
            throw AIError.modelUnavailable
        }
        let response = try await session.respond(to: prompt)
        return response.content
    }
}
