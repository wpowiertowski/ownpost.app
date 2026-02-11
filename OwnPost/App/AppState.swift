import SwiftUI
import Observation
import FoundationModels

/// Global app state — MainActor-isolated by default in Swift 6.2.
@MainActor
@Observable
final class AppState {
    var selectedNote: Note?
    var isEditorFocused: Bool = false
    var searchText: String = ""

    // Publishing state
    var isPublishing: Bool = false

    // AI availability (checked at launch)
    var isAIAvailable: Bool = SystemLanguageModel.default.isAvailable

    static let shared = AppState()

    private init() {}
}
